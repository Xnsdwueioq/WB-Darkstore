import SwiftUI
import Core
import DSKit

private struct OrderStatusPresentation {
    let title: String
    let isDelivered: Bool

    static func make(for order: Order) -> OrderStatusPresentation {
        switch order.status {
        case .completed:
            if let deliveryDate = order.deliveryDate, !deliveryDate.isEmpty {
                return OrderStatusPresentation(title: "Доставили \(deliveryDate)", isDelivered: true)
            }
            return OrderStatusPresentation(title: "Доставлено", isDelivered: true)
        case .active:
            return OrderStatusPresentation(title: "Доставляем ваш заказ", isDelivered: false)
        }
    }
}

struct OrderDetailView: View {
    let order: Order
    let onDismiss: () -> Void
    var onRepeatOrder: (() -> Void)? = nil
    var onDownloadReceipt: (() -> Void)? = nil

    private var statusPresentation: OrderStatusPresentation {
        OrderStatusPresentation.make(for: order)
    }

    private var addressDetailsLine: String {
        var parts: [String] = []
        if let floor = order.address.floor, !floor.isEmpty { parts.append("\(floor) этаж") }
        if let entrance = order.address.entrance, !entrance.isEmpty { parts.append("\(entrance) подъезд") }
        if let code = order.address.intercomCode, !code.isEmpty { parts.append("код домофона \(code)") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(statusPresentation.title)
                    .font(DSTypography.display)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(DSColors.secondary)
                        .padding(.trailing, DSSpacing.xxl)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.md)

            VStack(alignment: .leading) {
                Text(order.address.addressLine)
                    .font(DSTypography.body)
                    .foregroundColor(.primary)
                if !addressDetailsLine.isEmpty {
                    Text(addressDetailsLine)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.secondary)
                }
                if let comment = order.address.comment, !comment.isEmpty {
                    Text(comment)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.secondary)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.sm)
            .padding(.bottom, DSSpacing.xl)

            List {
                ForEach(order.items, id: \.id) { item in
                    OrderItemRowView(item: item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: DSSpacing.lg, trailing: 0))
                }

                VStack(spacing: DSSpacing.xs) {
                    HStack {
                        Text("Итого")
                            .font(DSTypography.bodyBold)
                        Spacer()
                        DSPriceText(Double(order.totalPrice), font: DSTypography.bodyBold)
                    }

                    HStack {
                        Text("\(order.totalItems) товар\(pluralSuffix(order.totalItems))")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.secondary)
                        Spacer()
                        DSPriceText(Double(order.orderPrice), font: DSTypography.caption)
                    }

                    HStack {
                        Text("Доставка")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.secondary)
                        Spacer()
                        if order.deliveryPrice == 0 {
                            Text("Бесплатно")
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.secondary)
                        } else {
                            DSPriceText(Double(order.deliveryPrice), font: DSTypography.caption)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                HStack(spacing: DSSpacing.sm) {
                    DSButton(
                        title: "Скачать чек",
                        style: .white,
                        size: .downloadReceipt,
                        fillWidth: false
                    ) {
                        onDownloadReceipt?() // заглушка
                    }

                    DSButton(
                        title: "Повторить заказ",
                        style: .gradient,
                        size: .medium,
                        fillWidth: true
                    ) {
                        onRepeatOrder?() // заглушка
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

struct OrderItemRowView: View {
    let item: OrderItem

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            ZStack {
                if let imageUrl = URL(string: item.image) {
                    CachedAsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .background(DSColors.secondary)

                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()

                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(DSColors.secondary)
                                .frame(width: 100, height: 100)
                                .background(DSColors.disabled)

                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(DSRadius.md)
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(DSColors.secondary)
                        .frame(width: 100, height: 100)
                        .background(DSColors.disabled)
                        .cornerRadius(DSRadius.md)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack (spacing: 0) {
                    DSPriceText(Double(item.price * item.quantity), font: DSTypography.bodyBold)
                    Text(", \(item.quantity) шт")
                        .font(DSTypography.bodyBold)
                }

                HStack(spacing: DSSpacing.sm) {
                    Text(item.name)
                        .font(DSTypography.caption)
                    Text("\(item.weight)г")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
    }
}
