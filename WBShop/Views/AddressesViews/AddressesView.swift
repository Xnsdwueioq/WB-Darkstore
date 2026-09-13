import SwiftUI
import MapKit
import Core
import DSKit
internal import Combine

final class AddressSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Обработка ошибок поиска
    }
}

struct AddressFormView: View {
    @Environment(\.dismiss) private var dismiss

    let addressToEdit: Components.Schemas.Address?
    let addressID: String?
    var onSave: (Components.Schemas.Address) -> Void
    var onUpdate: (String, Components.Schemas.Address) -> Void

    @State private var addressLine: String = ""
    @State private var comment: String = ""
    @State private var floor: String = ""
    @State private var entrance: String = ""
    @State private var intercomCode: String = ""

    @State private var cameraPosition: MapCameraPosition
    @State private var centerCoordinate: CLLocationCoordinate2D
    @State private var isGeocoding = false
    @State private var geocodeTask: Task<Void, Never>?
    
    @StateObject private var searchCompleter = AddressSearchCompleter()
    @State private var isSearching = false

    private var isEditing: Bool { addressToEdit != nil }

    init(
        addressToEdit: Components.Schemas.Address?,
        addressID: String?,
        onSave: @escaping (Components.Schemas.Address) -> Void,
        onUpdate: @escaping (String, Components.Schemas.Address) -> Void
    ) {
        self.addressToEdit = addressToEdit
        self.addressID = addressID
        self.onSave = onSave
        self.onUpdate = onUpdate

        let initialCoordinate: CLLocationCoordinate2D
        let coords = addressToEdit?.coordinates ?? []
        if coords.count == 2 {
            initialCoordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
        } else {
            initialCoordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        }

        _centerCoordinate = State(initialValue: initialCoordinate)
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: initialCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.md) {
                    mapPicker

                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        DSTextField(placeholder: "Введите адрес или выберите на карте", text: $addressLine)
                            .onChange(of: addressLine) { oldValue, newValue in
                                isSearching = true
                                searchCompleter.queryFragment = newValue
                            }
                       
                        if isSearching && !searchCompleter.searchResults.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(searchCompleter.searchResults, id: \.self) { result in
                                    Button {
                                        selectAddressCompletion(result)
                                    } label: {
                                        VStack(alignment: .leading, spacing: DSSpacing.sm) {
                                            Text(result.title)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            if !result.subtitle.isEmpty {
                                                Text(result.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, DSSpacing.sm)
                                        .padding(.horizontal, DSSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Divider()
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(DSRadius.md)
                            .shadow(radius: DSRadius.sm)
                        }
                    }

                    DSTextField(placeholder: "Этаж", text: $floor)
                    DSTextField(placeholder: "Подъезд", text: $entrance)
                    DSTextField(placeholder: "Домофон", text: $intercomCode)
                    DSTextField(placeholder: "Комментарий курьеру", text: $comment)
                }
                .padding(DSSpacing.lg)
            }
            .navigationTitle(isEditing ? "Редактировать" : "Новый адрес")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let address = Components.Schemas.Address(
                            coordinates: [centerCoordinate.latitude, centerCoordinate.longitude],
                            addressLine: addressLine,
                            floor: floor,
                            entrance: entrance,
                            intercomCode: intercomCode.isEmpty ? nil : intercomCode,
                            comment: comment.isEmpty ? nil : comment
                        )

                        if let id = addressID {
                            onUpdate(id, address)
                        } else {
                            onSave(address)
                        }
                        dismiss()
                    }
                    .disabled(addressLine.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let addressToEdit {
                    addressLine = addressToEdit.addressLine
                    comment = addressToEdit.comment ?? ""
                    floor = addressToEdit.floor ?? ""
                    entrance = addressToEdit.entrance ?? ""
                    intercomCode = addressToEdit.intercomCode ?? ""
                } else {
                    reverseGeocode(centerCoordinate)
                }
            }
        }
    }

    private var mapPicker: some View {
        ZStack {
            Map(position: $cameraPosition)
                .onMapCameraChange(frequency: .onEnd) { context in
                    centerCoordinate = context.region.center
                    if !isSearching {
                        reverseGeocode(centerCoordinate)
                    }
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                .onTapGesture {
                    isSearching = false
                    hideKeyboard()
                }

            Image(systemName: "mappin")
                .font(DSTypography.display)
                .foregroundColor(.red)
                .offset(y: -16)

            if isGeocoding {
                ProgressView()
                    .padding(DSSpacing.sm)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm))
                    .position(x: 40, y: 20)
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                isSearching = false
            }
        )
    }

    private func selectAddressCompletion(_ completion: MKLocalSearchCompletion) {
        isSearching = false
        hideKeyboard()
        
        Task {
            do {
                let searchRequest = MKLocalSearch.Request(completion: completion)
                let search = MKLocalSearch(request: searchRequest)
                let response = try await search.start()
                
                guard let coordinate = response.mapItems.first?.placemark.coordinate else { return }
                
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let geocoder = CLGeocoder()
                
                let placemarks = try? await geocoder.reverseGeocodeLocation(location)
                let placemark = placemarks?.first
                
                var formattedAddress = completion.title + (completion.subtitle.isEmpty ? "" : ", \(completion.subtitle)")
                
                if let placemark {
                    var components: [String] = []
                    
                    if let city = placemark.locality ?? placemark.subAdministrativeArea {
                        components.append(city)
                    }
                    if let street = placemark.thoroughfare {
                        components.append(street)
                    }
                    if let houseNumber = placemark.subThoroughfare {
                        components.append(houseNumber)
                    }
                    
                    if !components.isEmpty {
                        formattedAddress = components.joined(separator: ", ")
                    }
                }
                
                self.centerCoordinate = coordinate
                self.addressLine = formattedAddress
                
                withAnimation {
                    self.cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        )
                    )
                }
            } catch {
            }
        }
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        geocodeTask?.cancel()
         
        geocodeTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            isGeocoding = true
            defer { isGeocoding = false }

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()

            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard !Task.isCancelled, let placemark = placemarks.first else { return }

                var components: [String] = []
                 
                if let city = placemark.locality ?? placemark.subAdministrativeArea {
                    components.append(city)
                }
                 
                if let street = placemark.thoroughfare {
                    components.append(street)
                }
                 
                if let houseNumber = placemark.subThoroughfare {
                    components.append(houseNumber)
                }

                if !components.isEmpty && !isSearching {
                    addressLine = components.joined(separator: ", ")
                }
            } catch {
                // игнорируем ошибки отмены
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddressFormPayload: Identifiable {
    let id: String
    let address: Components.Schemas.Address?
    let addressID: String?
}

struct AddressesSelectionListView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected private var userService: UserServicing
    @Binding var selectedAddressId: String?
    @State private var formPayload: AddressFormPayload?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack() {
                Text("Мои адреса")
                    .font(DSTypography.display)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xl)
                    .padding(.bottom, DSSpacing.md)

                List {
                    ForEach(userService.addresses) { item in
                        addressRow(for: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    _ = await userService.deleteAddress(id: item.id)

                                    if selectedAddressId == item.id {
                                        selectedAddressId = userService.addresses.first { $0.id != item.id }?.id
                                    }
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }

                    Button {
                        formPayload = AddressFormPayload(id: "new", address: nil, addressID: nil)
                    } label: {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "plus")
                            Text("Новый адрес")
                        }
                        .foregroundColor(DSColors.black)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                DSButton(
                    title: "Привезти сюда",
                    style: .gradient,
                    size: .medium,
                    fillWidth: true
                ) {
                    dismiss()
                }
                .disabled(selectedAddressId == nil)
                .opacity(selectedAddressId == nil ? 0.5 : 1)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }

            DSCloseButton(action: { dismiss() })
                .padding(.top, DSSpacing.lg)
                .padding(.trailing, DSSpacing.md)
        }
        .sheet(item: $formPayload) { payload in
            AddressFormView(addressToEdit: payload.address, addressID: payload.addressID) { newAddress in
                Task { _ = await userService.addAddress(newAddress) }
            } onUpdate: { id, updatedAddress in
                Task { _ = await userService.updateAddress(id: id, updatedAddress) }
            }
        }
        .task {
            await userService.getAddresses()
            if selectedAddressId == nil {
                selectedAddressId = userService.addresses.first?.id
            }
        }
        .errorAlert(
            message: userService.errorMessage,
            onDismiss: {
                userService.clearErrorMessage()
            }
        )
    }

    @ViewBuilder
    private func addressRow(for item: IdentifiableAddress) -> some View {
        let isSelected = item.id == selectedAddressId

        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(item.address.addressLine)
                    .font(.body)
                let details = addressDetails(item.address)
                if !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button {
                formPayload = AddressFormPayload(id: item.id, address: item.address, addressID: item.id)
            } label: {
                Image("pencil")
                    .foregroundColor(DSColors.secondary)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 55)
        .padding(.horizontal, DSSpacing.sm)
        .background(isSelected ? DSColors.primary.opacity(0.1) : Color.clear)
        .cornerRadius(DSRadius.md)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedAddressId = item.id
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: DSSpacing.md, bottom: DSSpacing.sm, trailing: DSSpacing.md))
    }

    private func addressDetails(_ address: Components.Schemas.Address) -> String {
        var parts: [String] = []
        if let floor = address.floor, !floor.isEmpty { parts.append("\(floor) этаж") }
        if let entrance = address.entrance, !entrance.isEmpty { parts.append("\(entrance) подъезд") }
        if let code = address.intercomCode, !code.isEmpty { parts.append("код домофона \(code)") }
        return parts.joined(separator: ", ")
    }
}
