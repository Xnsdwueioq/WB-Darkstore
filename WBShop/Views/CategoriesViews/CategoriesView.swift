import SwiftUI
import Core
import DSKit

struct CategoriesView: View {
    @Injected var categoryService: CategoryServicing
    @Injected var router: Router

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.xs),
        GridItem(.flexible(), spacing: DSSpacing.xs),
        GridItem(.flexible(), spacing: DSSpacing.xs)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {

                Text("Каталог")
                    .font(DSTypography.display)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.sm_md)

                if categoryService.categories.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                        ForEach(categoryService.categories) { category in
                            CategoryCardView(category: category)
                                .onTapGesture {
                                    router.push(.category(id: category.id, name: category.name))
                                }
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                }
            }
            .padding(.bottom, 90)
        }
        .task {
            await categoryService.fetchCategories()
        }
        .errorAlert(
            message: categoryService.errorMessage,
            onDismiss: {
                categoryService.clearErrorMessage()
            }
        )
    }
}

struct CategoryCardView: View {
    let category: Category

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {

            CachedAsyncImage(url: URL(string: category.image)) { phase in
                switch phase {

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .empty:
                    ProgressView()

                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                        .foregroundColor(DSColors.secondary)

                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(DSColors.background)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))

            Text(category.name)
                .font(DSTypography.caption)
                .foregroundColor(.black)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .topLeading)
        }
    }
}
