import SwiftUI
import Core
import DesignSystem
import BusinessLogic

struct AddressFormPayload: Identifiable {
    let id: String
    let address: Address?
    let addressID: String?
}

struct AddressesSelectionListView: View {
    @Environment(\.dismiss) private var dismiss
    @Injected private var userService: UserServicing
    @Binding var selectedAddressId: String?
    @State private var formPayload: AddressFormPayload?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
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

    private func addressDetails(_ address: Address) -> String {
        var parts: [String] = []
        if let floor = address.floor, !floor.isEmpty { parts.append("\(floor) этаж") }
        if let entrance = address.entrance, !entrance.isEmpty { parts.append("\(entrance) подъезд") }
        if let code = address.intercomCode, !code.isEmpty { parts.append("код домофона \(code)") }
        return parts.joined(separator: ", ")
    }
}
