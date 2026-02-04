// Color manipulation utilities
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null;
}

function rgbToHex(r, g, b) {
  return (
    "#" +
    [r, g, b]
      .map((x) => {
        const hex = Math.round(Math.max(0, Math.min(255, x))).toString(16);
        return hex.length === 1 ? "0" + hex : hex;
      })
      .join("")
  );
}

function mixColors(color1, color2, weight = 0.5) {
  const rgb1 = hexToRgb(color1);
  const rgb2 = hexToRgb(color2);
  if (!rgb1 || !rgb2) return color1;

  return rgbToHex(
    rgb1.r * weight + rgb2.r * (1 - weight),
    rgb1.g * weight + rgb2.g * (1 - weight),
    rgb1.b * weight + rgb2.b * (1 - weight)
  );
}

function lighten(hex, amount) {
  return mixColors("#ffffff", hex, amount);
}

function darken(hex, amount) {
  return mixColors("#000000", hex, amount);
}

function generateColorVariables(colors) {
  const [primary, secondary, tertiary, headerBg, headerPrimary, highlight] =
    colors;

  // Determine if we're in dark mode (secondary is darker than primary)
  const secRgb = hexToRgb(secondary);
  const isDark = secRgb && (secRgb.r + secRgb.g + secRgb.b) / 3 < 128;

  // Generate selected/hover colors based on tertiary (like Horizon does)
  const selected = isDark
    ? mixColors(tertiary, secondary, 0.25)
    : mixColors(tertiary, secondary, 0.15);
  const hover = isDark
    ? mixColors(tertiary, secondary, 0.2)
    : mixColors(tertiary, secondary, 0.1);

  // RGB versions for rgba() usage
  const primaryRgb = hexToRgb(primary);
  const secondaryRgb = hexToRgb(secondary);
  const tertiaryRgb = hexToRgb(tertiary);
  const highlightRgb = hexToRgb(highlight);
  const headerBgRgb = hexToRgb(headerBg);

  const vars = {
    // Base colors - header uses secondary for unified Horizon-style look
    "--primary": primary,
    "--secondary": secondary,
    "--tertiary": tertiary,
    "--header_background": secondary,
    "--header_primary": primary,
    "--highlight": highlight,
    "--quaternary": tertiary,

    // RGB versions
    "--primary-rgb": primaryRgb ? `${primaryRgb.r}, ${primaryRgb.g}, ${primaryRgb.b}` : "0, 0, 0",
    "--secondary-rgb": secondaryRgb ? `${secondaryRgb.r}, ${secondaryRgb.g}, ${secondaryRgb.b}` : "255, 255, 255",
    "--tertiary-rgb": tertiaryRgb ? `${tertiaryRgb.r}, ${tertiaryRgb.g}, ${tertiaryRgb.b}` : "0, 0, 0",
    "--highlight-rgb": highlightRgb ? `${highlightRgb.r}, ${highlightRgb.g}, ${highlightRgb.b}` : "0, 0, 0",
    "--header_background-rgb": secondaryRgb ? `${secondaryRgb.r}, ${secondaryRgb.g}, ${secondaryRgb.b}` : "255, 255, 255",

    // Primary variants (text on background)
    "--primary-very-low": mixColors(primary, secondary, 0.1),
    "--primary-low": mixColors(primary, secondary, isDark ? 0.2 : 0.15),
    "--primary-low-mid": mixColors(primary, secondary, isDark ? 0.35 : 0.3),
    "--primary-medium": mixColors(primary, secondary, isDark ? 0.5 : 0.45),
    "--primary-high": mixColors(primary, secondary, isDark ? 0.75 : 0.7),
    "--primary-very-high": mixColors(primary, secondary, isDark ? 0.9 : 0.85),

    // Secondary variants (background)
    "--secondary-very-low": isDark ? lighten(secondary, 0.03) : darken(secondary, 0.02),
    "--secondary-low": isDark ? lighten(secondary, 0.07) : darken(secondary, 0.05),
    "--secondary-medium": isDark ? lighten(secondary, 0.15) : darken(secondary, 0.1),
    "--secondary-high": isDark ? lighten(secondary, 0.25) : darken(secondary, 0.2),
    "--secondary-very-high": isDark ? lighten(secondary, 0.35) : darken(secondary, 0.3),

    // Tertiary variants (accent color)
    "--tertiary-very-low": mixColors(tertiary, secondary, 0.05),
    "--tertiary-low": mixColors(tertiary, secondary, isDark ? 0.15 : 0.1),
    "--tertiary-medium": mixColors(tertiary, secondary, isDark ? 0.35 : 0.3),
    "--tertiary-high": mixColors(tertiary, primary, 0.3),
    "--tertiary-hover": isDark ? lighten(tertiary, 0.1) : darken(tertiary, 0.1),

    // Highlight variants
    "--highlight-low": mixColors(highlight, secondary, 0.15),
    "--highlight-medium": mixColors(highlight, secondary, 0.4),
    "--highlight-high": mixColors(highlight, primary, 0.6),

    // Header variants (uses primary/secondary for unified look)
    "--header_primary-very-high": mixColors(primary, secondary, 0.85),
    "--header_primary-high": mixColors(primary, secondary, 0.7),
    "--header_primary-medium": mixColors(primary, secondary, 0.5),
    "--header_primary-low-mid": mixColors(primary, secondary, 0.4),
    "--header_primary-low": mixColors(primary, secondary, 0.3),
    "--header_primary-very-low": mixColors(primary, secondary, 0.15),

    // Common UI colors
    "--danger": "#e45735",
    "--danger-low": isDark ? mixColors("#e45735", secondary, 0.15) : mixColors("#e45735", secondary, 0.1),
    "--danger-medium": mixColors("#e45735", secondary, 0.35),
    "--success": "#009900",
    "--success-low": isDark ? mixColors("#009900", secondary, 0.15) : mixColors("#009900", secondary, 0.1),
    "--love": "#fa6c8d",
    "--love-low": mixColors("#fa6c8d", secondary, 0.15),

    // Horizon-specific: selected and hover states
    "--d-selected": selected,
    "--d-hover": hover,
    "--selected-hover": isDark ? lighten(selected, 0.05) : darken(selected, 0.05),

    // Sidebar (comprehensive)
    "--d-sidebar-background": secondary,
    "--d-sidebar-highlight-background": selected,
    "--d-sidebar-highlight-hover-background": hover,
    "--d-sidebar-row-hover-background": hover,
    "--d-sidebar-link-color": primary,
    "--d-sidebar-link-icon-color": mixColors(primary, secondary, 0.6),
    "--d-sidebar-header-color": mixColors(primary, secondary, 0.7),
    "--d-sidebar-header-icon-color": mixColors(primary, secondary, 0.5),
    "--d-sidebar-active-color": primary,
    "--d-sidebar-active-background": selected,
    "--d-sidebar-highlight-color": primary,
    "--d-sidebar-border-color": isDark ? lighten(secondary, 0.1) : darken(secondary, 0.1),
    "--d-sidebar-section-border-color": isDark ? lighten(secondary, 0.08) : darken(secondary, 0.08),
    "--d-sidebar-suffix-color": mixColors(primary, secondary, 0.5),
    "--d-sidebar-prefix-color": mixColors(primary, secondary, 0.6),

    // Navigation
    "--d-nav-color": mixColors(primary, secondary, 0.7),
    "--d-nav-color--hover": primary,
    "--d-nav-color--active": primary,
    "--d-nav-bg-color--hover": hover,
    "--d-nav-bg-color--active": selected,
    "--d-nav-border-color--active": tertiary,
    "--d-link-color": tertiary,

    // Topic list
    "--d-topic-list-item-background-color": secondary,
    "--d-topic-list-item-background-color--visited": isDark ? lighten(secondary, 0.02) : darken(secondary, 0.01),
    "--d-topic-list-header-background-color": isDark ? lighten(secondary, 0.05) : darken(secondary, 0.03),
    "--d-topic-list-header-text-color": mixColors(primary, secondary, 0.6),

    // Buttons - default
    "--d-button-default-bg-color": isDark ? lighten(secondary, 0.1) : darken(secondary, 0.05),
    "--d-button-default-bg-color--hover": isDark ? lighten(secondary, 0.15) : darken(secondary, 0.1),
    "--d-button-default-text-color": primary,
    "--d-button-default-text-color--hover": primary,
    "--d-button-default-icon-color": mixColors(primary, secondary, 0.7),
    "--d-button-default-icon-color--hover": primary,

    // Buttons - primary
    "--d-button-primary-bg-color": tertiary,
    "--d-button-primary-bg-color--hover": isDark ? lighten(tertiary, 0.1) : darken(tertiary, 0.1),
    "--d-button-primary-text-color": "#ffffff",
    "--d-button-primary-text-color--hover": "#ffffff",
    "--d-button-primary-icon-color": "#ffffff",
    "--d-button-primary-icon-color--hover": "#ffffff",

    // Buttons - flat
    "--d-button-flat-bg-color--hover": hover,
    "--d-button-flat-icon-color": mixColors(primary, secondary, 0.6),
    "--d-button-flat-icon-color--hover": primary,

    // Content background
    "--d-content-background": secondary,

    // Input fields
    "--d-input-bg-color": secondary,
    "--d-input-text-color": primary,
    "--d-input-border": isDark ? lighten(secondary, 0.2) : darken(secondary, 0.15),
    "--input-border-color": isDark ? lighten(secondary, 0.2) : darken(secondary, 0.15),

    // Tags
    "--d-tag-background-color": isDark ? lighten(secondary, 0.1) : darken(secondary, 0.05),
    "--tag-text-color": mixColors(primary, secondary, 0.7),

    // Misc
    "--d-unread-notification-background": mixColors(tertiary, secondary, 0.2),

    // Search box - give it a visible border/background
    "--search-bg": isDark ? lighten(secondary, 0.08) : darken(secondary, 0.03),
    "--search-border": isDark ? lighten(secondary, 0.2) : darken(secondary, 0.12),
  };

  return vars;
}

export default {
  name: "inject-custom-colors",

  initialize(owner) {
    const currentUser = owner.lookup("service:current-user");
    if (!currentUser) {
      return;
    }

    const colorString = currentUser.custom_fields?.custom_color_string;
    console.log("[custom-colors] colorString from user:", colorString);
    if (!colorString) {
      return;
    }

    const hexRegex = /#[0-9A-Fa-f]{6}\b/g;
    const colors = colorString.match(hexRegex);
    if (!colors || colors.length < 6) {
      return;
    }

    const vars = generateColorVariables(colors);

    let css = ":root {\n";
    for (const [key, value] of Object.entries(vars)) {
      css += `  ${key}: ${value} !important;\n`;
    }
    css += "}";

    const style = document.createElement("style");
    style.id = "custom-user-colors";
    style.textContent = css;
    document.head.appendChild(style);
  },
};
