// uretildi: node tools/gen-tokens.mjs — elle duzenleme, tokens/tokens.json'u degistir
import SwiftUI

public enum DesignTokens {
    public static let colorTimber50: Color = Color(hex: 0xFAF8F5)
    public static let colorTimber100: Color = Color(hex: 0xF5F0E6)
    public static let colorTimber200: Color = Color(hex: 0xE7E5E4)
    public static let colorTimber300: Color = Color(hex: 0xA8A29E)
    public static let colorTimber500: Color = Color(hex: 0x78716C)
    public static let colorTimber700: Color = Color(hex: 0x44403C)
    public static let colorTimber800: Color = Color(hex: 0x292524)
    public static let colorTimber900: Color = Color(hex: 0x1C1917)
    public static let colorTimber950: Color = Color(hex: 0x141210)
    public static let colorAmber400: Color = Color(hex: 0xFBBF24)
    public static let colorAmber500: Color = Color(hex: 0xF59E0B)
    public static let colorAmber600: Color = Color(hex: 0xD97706)
    public static let colorAmber700: Color = Color(hex: 0xB45309)
    public static let colorAmber800: Color = Color(hex: 0x92400E)
    public static let colorWalnut600: Color = Color(hex: 0x8A5A2B)
    public static let colorOak500: Color = Color(hex: 0xC9A227)
    public static let colorGreen500: Color = Color(hex: 0x34D399)
    public static let colorGreen700: Color = Color(hex: 0x047857)
    public static let colorRed500: Color = Color(hex: 0xF87171)
    public static let colorRed700: Color = Color(hex: 0xB91C1C)
    public static let colorBlue500: Color = Color(hex: 0x60A5FA)
    public static let colorBlue700: Color = Color(hex: 0x1D4ED8)
    public static let colorBgCanvas: Color = Color(hex: 0xFAF8F5)
    public static let colorBgSurface: Color = Color(hex: 0xFFFFFF)
    public static let colorBgRaised: Color = Color(hex: 0xE7E5E4)
    public static let colorTextPrimary: Color = Color(hex: 0x1C1917)
    public static let colorTextSecondary: Color = Color(hex: 0x57534E)
    public static let colorTextOnAccent: Color = Color(hex: 0x141210)
    public static let colorAccentDefault: Color = Color(hex: 0xB45309)
    public static let colorAccentPressed: Color = Color(hex: 0x92400E)
    public static let colorAccentBright: Color = Color(hex: 0xD97706)
    public static let colorBorder: Color = Color(hex: 0xD6D3D1)
    public static let colorSuccess: Color = Color(hex: 0x047857)
    public static let colorDanger: Color = Color(hex: 0xB91C1C)
    public static let colorInfo: Color = Color(hex: 0x1D4ED8)
    public static let colorDiagramSheetBg: Color = Color(hex: 0xFFFFFF)
    public static let colorDiagramKerfLine: Color = Color(hex: 0xB45309)
    public static let colorDiagramMaterial1: Color = Color(hex: 0xE8C89E)
    public static let colorDiagramMaterial2: Color = Color(hex: 0xB7CDB0)
    public static let colorDiagramMaterial3: Color = Color(hex: 0xAFC3D9)
    public static let colorDiagramMaterial4: Color = Color(hex: 0xD9B8C4)
    public static let colorDiagramWasteHatch: Color = Color(hex: 0x78716C)
    public static let space100: CGFloat = 4
    public static let space200: CGFloat = 8
    public static let space300: CGFloat = 12
    public static let space400: CGFloat = 16
    public static let space500: CGFloat = 24
    public static let space600: CGFloat = 32
    public static let space700: CGFloat = 48
    public static let radiusControl: CGFloat = 8
    public static let radiusCard: CGFloat = 12
    public static let radiusPanel: CGFloat = 16
    public static let sizeTouch: CGFloat = 44
    public static let sizeTouchWorkshop: CGFloat = 60
    public static let fontSizeDisplay: CGFloat = 34
    public static let fontSizeTitle: CGFloat = 28
    public static let fontSizeHeadline: CGFloat = 22
    public static let fontSizeBody: CGFloat = 17
    public static let fontSizeCallout: CGFloat = 15
    public static let fontSizeCaption: CGFloat = 13

    // Dark mod override'ları (koyu-öncelikli marka: uygulama kabuğu bunları kullanır)
    public enum Dark {
        public static let colorBgCanvas: Color = Color(hex: 0x141210)
        public static let colorBgSurface: Color = Color(hex: 0x1C1917)
        public static let colorBgRaised: Color = Color(hex: 0x292524)
        public static let colorTextPrimary: Color = Color(hex: 0xF5F0E6)
        public static let colorTextSecondary: Color = Color(hex: 0xA8A29E)
        public static let colorAccentDefault: Color = Color(hex: 0xF59E0B)
        public static let colorAccentPressed: Color = Color(hex: 0xD97706)
        public static let colorAccentBright: Color = Color(hex: 0xFBBF24)
        public static let colorBorder: Color = Color(hex: 0x44403C)
        public static let colorSuccess: Color = Color(hex: 0x34D399)
        public static let colorDanger: Color = Color(hex: 0xF87171)
        public static let colorInfo: Color = Color(hex: 0x60A5FA)
        public static let colorDiagramSheetBg: Color = Color(hex: 0x292524)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
