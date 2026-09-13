import SwiftUI
import DSKit
import Core

struct SearchBarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Image("search")
                    .frame(width: 33, height: 33)

                Text("Поиск")
                    .font(DSTypography.order)
                    .foregroundColor(DSColors.black)
            }
            .frame(width: 129, height: 50)
            .background(DSColors.background.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(.black.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SearchView: View {
    @State private var query = ""
    @State private var selectedProduct: ProductPreview?
    @State private var searchResults: [ProductPreview] = []
    
    @Injected private var searchService: SearchServicing
    @Injected private var productService: ProductServicing

    var body: some View {
        VStack(spacing: 0) {
            if query.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(searchService.recentSearches, id: \.self) { recent in
                            SuggestionRow(text: recent) {
                                query = recent
                            }
                        }
                    }
                    .padding(.top, DSSpacing.md)
                }
                Spacer()
            } else if searchResults.isEmpty {
                Spacer()
                Text("Ничего не найдено")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.secondary)
                Spacer()
            } else {
                ProductGridView(
                    products: searchResults,
                    onSelectProduct: { selectedProduct = $0 },
                    isFavorite: { productService.isFavorite(id: $0) },
                    onToggleFavorite: { product in
                        Task { await productService.toggleFavorite(id: product.id) }
                    }
                )
            }

            DSTextField(placeholder: "Поиск", text: $query)
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.sm)
                .onSubmit {
                    saveRecentSearch(query)
                }
        }
        .background(DSColors.surface)
        .task(id: query) {
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                searchResults = []
                return
            }

            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            searchResults = searchService.search(query: trimmed)
        }
        .sheet(item: $selectedProduct) { preview in
            ProductDetailContainerView(previewID: preview.id) {
                selectedProduct = nil
            }
            .presentationDetents([.large])
        }
        .errorAlert(
            message: productService.errorMessage,
            onDismiss: {
                productService.clearError()
            }
        )
    }

    private func saveRecentSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !searchService.recentSearches.contains(trimmed) else { return }

        searchService.recentSearches.insert(trimmed, at: 0)
        if searchService.recentSearches.count > 10 {
            searchService.recentSearches.removeLast()
        }
    }
}

struct SuggestionRow: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(DSTypography.body)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm_md)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
