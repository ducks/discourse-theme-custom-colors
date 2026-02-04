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

  const vars = {
    // Base colors
    "--primary": primary,
    "--secondary": secondary,
    "--tertiary": tertiary,
    "--header_background": headerBg,
    "--header_primary": headerPrimary,
    "--highlight": highlight,
    "--quaternary": tertiary,

    // Primary variants (text on background)
    "--primary-very-low": isDark
      ? mixColors(primary, secondary, 0.1)
      : mixColors(primary, secondary, 0.1),
    "--primary-low": isDark
      ? mixColors(primary, secondary, 0.2)
      : mixColors(primary, secondary, 0.15),
    "--primary-low-mid": isDark
      ? mixColors(primary, secondary, 0.35)
      : mixColors(primary, secondary, 0.3),
    "--primary-medium": isDark
      ? mixColors(primary, secondary, 0.5)
      : mixColors(primary, secondary, 0.45),
    "--primary-high": isDark
      ? mixColors(primary, secondary, 0.75)
      : mixColors(primary, secondary, 0.7),
    "--primary-very-high": isDark
      ? mixColors(primary, secondary, 0.9)
      : mixColors(primary, secondary, 0.85),

    // Secondary variants (background)
    "--secondary-very-low": isDark ? lighten(secondary, 0.03) : darken(secondary, 0.02),
    "--secondary-low": isDark ? lighten(secondary, 0.07) : darken(secondary, 0.05),
    "--secondary-medium": isDark ? lighten(secondary, 0.15) : darken(secondary, 0.1),
    "--secondary-high": isDark ? lighten(secondary, 0.25) : darken(secondary, 0.2),
    "--secondary-very-high": isDark ? lighten(secondary, 0.35) : darken(secondary, 0.3),

    // Tertiary variants (accent color)
    "--tertiary-low": isDark
      ? mixColors(tertiary, secondary, 0.15)
      : mixColors(tertiary, secondary, 0.1),
    "--tertiary-medium": isDark
      ? mixColors(tertiary, secondary, 0.35)
      : mixColors(tertiary, secondary, 0.3),
    "--tertiary-high": mixColors(tertiary, primary, 0.3),
    "--tertiary-hover": isDark ? lighten(tertiary, 0.1) : darken(tertiary, 0.1),

    // Highlight variants
    "--highlight-low": mixColors(highlight, secondary, 0.15),
    "--highlight-medium": mixColors(highlight, secondary, 0.4),
    "--highlight-high": mixColors(highlight, primary, 0.6),

    // Header variants
    "--header_primary-very-high": mixColors(headerPrimary, headerBg, 0.85),
    "--header_primary-high": mixColors(headerPrimary, headerBg, 0.7),
    "--header_primary-medium": mixColors(headerPrimary, headerBg, 0.5),
    "--header_primary-low": mixColors(headerPrimary, headerBg, 0.3),
    "--header_primary-very-low": mixColors(headerPrimary, headerBg, 0.15),

    // Common UI colors
    "--danger": "#e45735",
    "--success": "#009900",
    "--love": "#fa6c8d",

    // D-* colors (used in various components)
    "--d-sidebar-background": headerBg,
    "--d-sidebar-highlight-background": isDark
      ? lighten(headerBg, 0.08)
      : darken(headerBg, 0.05),
    "--d-sidebar-row-hover-background": isDark
      ? lighten(headerBg, 0.05)
      : darken(headerBg, 0.03),
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
