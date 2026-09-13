import SwiftUI
import DSKit
import Core

extension IdentifiableAddress {
    var formattedDetails: String {
        var parts: [String] = []
        if let floor = address.floor, !floor.isEmpty { parts.append("\(floor) этаж") }
        if let entrance = address.entrance, !entrance.isEmpty { parts.append("\(entrance) подъезд") }
        if let code = address.intercomCode, !code.isEmpty { parts.append("код домофона \(code)") }
        return parts.joined(separator: ", ")
    }
}

struct AddressSelectorView: View {
    @AppStorage("selectedAddressId") private var selectedAddressId: String = ""
    @Injected private var userService: UserServicing
    @State private var isShowingAddressSelection = false

    private var selectedAddressBinding: Binding<String?> {
        Binding(
            get: { selectedAddressId.isEmpty ? nil : selectedAddressId },
            set: { selectedAddressId = $0 ?? "" }
        )
    }

    private var selectedAddress: IdentifiableAddress? {
        if !selectedAddressId.isEmpty, let address = userService.addresses.first(where: { $0.id == selectedAddressId }) {
            return address
        }
        return userService.addresses.first
    }

    private var currentAddressLine: String {
        selectedAddress?.address.addressLine ?? "Добавить адрес доставки"
    }

    private var currentAddressDetails: String {
        selectedAddress?.formattedDetails ?? ""
    }

    var body: some View {
        Button {
            isShowingAddressSelection = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xs) {
                        Text(currentAddressLine)
                            .font(DSTypography.bodyBold)
                            .foregroundColor(DSColors.black)
                            .lineLimit(1)

                        Image(systemName: "chevron.right")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.black)
                    }

                    if !currentAddressDetails.isEmpty {
                        Text(currentAddressDetails)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.black)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: DSSpacing.xs)
            }
        }
        .buttonStyle(.plain)
        .task {
            if userService.addresses.isEmpty {
                await userService.getAddresses()
            }
            if selectedAddressId.isEmpty, let firstId = userService.addresses.first?.id {
                selectedAddressId = firstId
            }
        }
        .sheet(isPresented: $isShowingAddressSelection) {
            AddressesSelectionListView(selectedAddressId: selectedAddressBinding)
        }
    }
}
