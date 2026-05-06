import SwiftUI

struct BeautynAlertIconView: View {
    let variant: BeautynAlertVariant

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(variant.tint.opacity(0.20))

            Image(variant.iconAssetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(variant.tint)
                .padding(6)
        }
        .frame(width: 32, height: 32)
    }
}

#Preview {
    HStack(spacing: 12) {
        BeautynAlertIconView(variant: .error)
        BeautynAlertIconView(variant: .warning)
        BeautynAlertIconView(variant: .success)
    }
    .padding()
}
