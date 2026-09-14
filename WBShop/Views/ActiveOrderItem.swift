import SwiftUI
import Core
import DSKit

struct ActiveOrderCard: View {
    let order: Order
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        (Text("Доставим через ") + Text("N минут"))
                            .font(DSTypography.order.weight(.regular))
                            .foregroundColor(DSColors.black)

                        Text(order.address.addressLine)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.secondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.sm) {
                        ForEach(order.items, id: \.id) { item in
                            orderItemCell(item)
                        }
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(DSColors.lightPurple)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func orderItemCell(_ item: OrderItem) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            AsyncImage(url: URL(string: item.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    Rectangle()
                        .fill(DSColors.disabled.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(DSColors.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack(spacing: 4) {
                Text(item.name)
                    .lineLimit(1)
                    .foregroundColor(DSColors.black)

                Text("\(item.weight) г")
                    .foregroundColor(DSColors.secondary)
            }
            .font(DSTypography.caption)
            .frame(maxWidth: 96, alignment: .leading)
        }
    }
}
