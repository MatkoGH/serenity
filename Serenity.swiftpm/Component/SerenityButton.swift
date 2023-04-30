import SwiftUI

// MARK: - Serenity Button

struct SerenityButton: View {
    
    /// The button's title.
    var title: String
    
    /// The name of the icon to have on the button.
    var iconName: String
    
    /// Boolean indicating whether the button should only show the icon.
    var iconOnly: Bool
    
    /// The action for the button to perform on press.
    var action: () -> Void
    
    // MARK: Init
    
    init(_ title: String, icon iconName: String, iconOnly: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        
        self.iconOnly = iconOnly
        
        self.action = action
    }
    
    // MARK: Content
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                if !iconOnly {
                    Text(title)
                    Spacer(minLength: 8)
                }
                
                Image(systemName: iconName)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minWidth: 256, minHeight: 48, idealHeight: 48)
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.serenity(background: Color.dynamicSerenityGreen))
    }
}

// MARK: - Serenity Back Button

struct SerenitySecondaryButton: View {
    
    /// An optional title for the button.
    var title: String
    
    /// The name of the icon to have on the button.
    var iconName: String
    
    /// Boolean indicating whether the button should only show the icon.
    var iconOnly: Bool
    
    /// The action for the button to perform on press.
    var action: () -> Void
    
    // MARK: Init
    
    init(_ title: String, icon iconName: String, iconOnly: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        
        self.iconOnly = iconOnly
        
        self.action = action
    }
    
    // MARK: Content
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                
                if !iconOnly {
                    Text(title)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minWidth: 48, minHeight: 48, idealHeight: 48)
        }
        .buttonStyle(.serenity(background: .ultraThinMaterial))
    }
}

// MARK: - Style

struct SerenityButtonStyle<S>: ButtonStyle where S: ShapeStyle {
    
    @Environment(\.hidden) var hidden
    
    /// The style to apply to the background.
    var backgroundStyle: S
    
    // MARK: Protocol
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.buttonTitle)
            .foregroundColor(.primary)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(backgroundStyle)
            }
            .scaleEffect(isPressed ? 0.94 : 1)
            .opacity(isPressed ? 0.75 : 1)
            .brightness(isPressed ? -0.1 : 0)
            .animation(.button, value: isPressed)
            .opacity(hidden ? 0 : 1)
            .scaleEffect(hidden ? 0.86 : 1)
            .blur(radius: hidden ? 8 : 0)
            .disabled(hidden)
    }
}

extension ButtonStyle where Self == SerenityButtonStyle<AnyShapeStyle> {
    
    static func serenity<S>(background backgroundStyle: S) -> SerenityButtonStyle<S> where S: ShapeStyle {
        SerenityButtonStyle(backgroundStyle: backgroundStyle)
    }
}
