import SwiftUI
import CutModels

// E4-S2b kesir pad'i (docs/13 M-2, docs/03 AC: 1/2..63/64 tam liste kaydırmalı; 60pt tuşlar).
// Değer 1/64″ adedi olarak tutulur: 30 1/2″ → 1952.
struct FractionField: View {
    let label: String
    let id: String
    @Binding var frac64: Int
    @State private var padOpen = false

    var body: some View {
        Button {
            padOpen = true
        } label: {
            HStack {
                Text(label)
                Spacer()
                Text(UnitFormat.fraction(frac64: frac64) + "\u{2033}")
                    .font(.body.monospacedDigit())
                    .foregroundStyle(DesignTokens.colorAmber400)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .accessibilityIdentifier(id)
        .accessibilityValue(UnitFormat.fraction(frac64: frac64) + " inches")
        .sheet(isPresented: $padOpen) {
            FractionPad(title: label, frac64: $frac64)
                .presentationDetents([.medium])
                .preferredColorScheme(.dark)
        }
    }
}

struct FractionPad: View {
    let title: String
    @Binding var frac64: Int
    @Environment(\.dismiss) private var dismiss

    @State private var whole: Int = 0
    @State private var numerator64: Int = 0 // 0..63 (1/64 adımında pay)

    // Hızlı şerit — atölyede en sık kullanılanlar (docs/13).
    private static let quick: [Int] = [32, 16, 48, 8, 24, 40, 56] // 1/2 1/4 3/4 1/8 3/8 5/8 7/8

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title).font(.headline).foregroundStyle(DesignTokens.colorTimber50)
                Spacer()
                Text(UnitFormat.fraction(frac64: whole * 64 + numerator64) + "\u{2033}")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(DesignTokens.colorAmber500)
                    .accessibilityIdentifier("pad.value")
            }
            .padding(.top, 16)

            // Tam sayı tuşları
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...9, id: \.self) { digit in
                    key("\(digit)") { whole = min(whole * 10 + digit, 9999) }
                }
                key("0") { whole = min(whole * 10, 9999) }
                key("⌫") { whole /= 10 }
                    .accessibilityLabel(String(localized: "Delete digit"))
            }

            // Hızlı kesirler
            HStack(spacing: 8) {
                ForEach(Self.quick, id: \.self) { n in
                    key(UnitFormat.fraction(frac64: n), active: numerator64 == n) {
                        numerator64 = numerator64 == n ? 0 : n
                    }
                }
            }

            // Tam liste: 1/64..63/64 (AC) — kaydırmalı
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1..<64, id: \.self) { n in
                        key(UnitFormat.fraction(frac64: n), active: numerator64 == n, wide: true) {
                            numerator64 = numerator64 == n ? 0 : n
                        }
                    }
                }
            }
            .frame(height: 60)

            Button {
                frac64 = whole * 64 + numerator64
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.colorAmber500)
            .foregroundStyle(DesignTokens.colorTimber950)
            .accessibilityIdentifier("pad.done")
        }
        .padding(.horizontal)
        .background(DesignTokens.colorTimber950)
        .onAppear { whole = frac64 / 64; numerator64 = frac64 % 64 }
    }

    private func key(_ text: String, active: Bool = false, wide: Bool = false,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.title3.weight(.bold).monospacedDigit())
                .frame(minWidth: wide ? 72 : 0, maxWidth: wide ? nil : .infinity, minHeight: 60)
                .background(active ? DesignTokens.colorAmber500 : DesignTokens.colorTimber800,
                            in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(active ? DesignTokens.colorTimber950 : DesignTokens.colorTimber50)
        }
        .buttonStyle(.plain)
    }
}
