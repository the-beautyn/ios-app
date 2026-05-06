import SwiftUI

struct BeautynAlertView: View {
    let content: BeautynAlertContent

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            BeautynAlertIconView(variant: content.variant)
            textBlock
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.20), radius: 18, x: 0, y: 4)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var textBlock: some View {
        if let title = content.title {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.App.headline)
                    .tracking(.Tracking.body)
                    .foregroundStyle(Color.App.text)
                    .lineSpacing(22 - 17)

                Text(content.message)
                    .font(.App.footnote)
                    .tracking(.Tracking.subheadline)
                    .foregroundStyle(Color.App.gray2)
                    .lineSpacing(20 - 13)
            }
        } else {
            Text(content.message)
                .font(.App.subheadline)
                .tracking(.Tracking.caption2)
                .foregroundStyle(Color.App.text)
                .lineSpacing(17 - 15)
        }
    }
}

#Preview("Error") {
    BeautynAlertView(content: .error("Something went wrong. Try again or later."))
        .padding(.top, 60)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.gray.opacity(0.15))
}

#Preview("Warning (attributed)") {
    BeautynAlertView(content: .warning("Reminder for the **Appointment** is set."))
        .padding(.top, 60)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.gray.opacity(0.15))
}

#Preview("Success (title + description)") {
    BeautynAlertView(
        content: .success(
            title: "Well done! 🎉",
            message: "You already booked appointment in 26 May 2026"
        )
    )
    .padding(.top, 60)
    .frame(maxHeight: .infinity, alignment: .top)
    .background(Color.gray.opacity(0.15))
}
