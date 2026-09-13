import SwiftUI
import DSKit
import Core

struct OrderHistoryView: View {
    @Injected var service: UserServicing
    @State private var selectedOrder: Order?

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(service.orders) { order in
                    OrderHistoryItem(order: order) {
                        selectedOrder = order
                    }
                }
            }
        }
        .task {
            await service.getOrders()
        }
        .sheet(item: $selectedOrder) { order in
            OrderDetailView(
                order: order,
                onDismiss: {
                    selectedOrder = nil
                }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(DSRadius.sheet)
        }
    }
}

struct OrderHistoryItem: View {
    let order: Order
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(order.totalPrice)₽")
                                .foregroundStyle(DSColors.black)
                            Text("\(order.totalItems) товар\(pluralSuffix(order.totalItems))")
                                .foregroundStyle(DSColors.secondary)
                        }
                        .font(DSTypography.priceBold.weight(.semibold))
                        Text(order.deliveryDate ?? "")
                            .foregroundStyle(DSColors.black)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DSTypography.bodyBold)
                        .foregroundColor(DSColors.secondary.opacity(0.5))
                }
                Spacer()
            }
            .padding(DSSpacing.lg)
            .background(DSColors.smoky)
            .cornerRadius(DSRadius.lg)
        }
    }
}
