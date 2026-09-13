import SwiftUI
import CoreText

public enum FontRegister {
    public static func registerFonts() {
        guard let url = Bundle.module.url(forResource: "Inter-VariableFont_opsz,wght", withExtension: "ttf") else {
            print("Ошибка: Файл шрифта Inter не найден в Bundle.module")
            return
        }
        
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        
        if let error = error?.takeRetainedValue() {
            print("Ошибка регистрации шрифта: \(error)")
        }
    }
}
