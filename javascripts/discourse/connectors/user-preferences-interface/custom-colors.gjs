import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { fn, get } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import i18n from "discourse-common/helpers/i18n";

export default class CustomColors extends Component {
  @service currentUser;
  @tracked colorString = "";
  @tracked saving = false;
  @tracked saved = false;

  constructor() {
    super(...arguments);
    this.colorString = this.currentUser?.custom_fields?.custom_color_string || "";
  }

  get colors() {
    const hexRegex = /#[0-9A-Fa-f]{6}\b/g;
    const matches = this.colorString.match(hexRegex);
    return matches || [];
  }

  get colorLabels() {
    return [
      "primary",
      "secondary",
      "tertiary",
      "header-bg",
      "header-text",
      "highlight",
    ];
  }

  @action
  updateColorString(event) {
    this.colorString = event.target.value;
    this.saved = false;
  }

  @action
  async saveColors() {
    this.saving = true;
    try {
      await ajax(`/u/${this.currentUser.username}.json`, {
        type: "PUT",
        data: {
          custom_fields: {
            custom_color_string: this.colorString,
          },
        },
      });
      this.currentUser.custom_fields.custom_color_string = this.colorString;
      this.saved = true;

      // Apply colors immediately
      this.applyColors();
    } catch (e) {
      console.error("Failed to save custom colors:", e);
    } finally {
      this.saving = false;
    }
  }

  @action
  clearColors() {
    this.colorString = "";
    this.saved = false;
  }

  hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null;
  }

  rgbToHex(r, g, b) {
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

  mixColors(color1, color2, weight = 0.5) {
    const rgb1 = this.hexToRgb(color1);
    const rgb2 = this.hexToRgb(color2);
    if (!rgb1 || !rgb2) return color1;

    return this.rgbToHex(
      rgb1.r * weight + rgb2.r * (1 - weight),
      rgb1.g * weight + rgb2.g * (1 - weight),
      rgb1.b * weight + rgb2.b * (1 - weight)
    );
  }

  lighten(hex, amount) {
    return this.mixColors("#ffffff", hex, amount);
  }

  darken(hex, amount) {
    return this.mixColors("#000000", hex, amount);
  }

  generateColorVariables(colors) {
    const [primary, secondary, tertiary, headerBg, headerPrimary, highlight] = colors;

    const secRgb = this.hexToRgb(secondary);
    const isDark = secRgb && (secRgb.r + secRgb.g + secRgb.b) / 3 < 128;

    // Generate selected/hover colors based on tertiary (like Horizon does)
    const selected = isDark
      ? this.mixColors(tertiary, secondary, 0.25)
      : this.mixColors(tertiary, secondary, 0.15);
    const hover = isDark
      ? this.mixColors(tertiary, secondary, 0.2)
      : this.mixColors(tertiary, secondary, 0.1);

    // RGB versions for rgba() usage
    const primaryRgb = this.hexToRgb(primary);
    const secondaryRgb = this.hexToRgb(secondary);
    const tertiaryRgb = this.hexToRgb(tertiary);
    const highlightRgb = this.hexToRgb(highlight);
    const headerBgRgb = this.hexToRgb(headerBg);

    return {
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

      // Primary variants
      "--primary-very-low": this.mixColors(primary, secondary, 0.1),
      "--primary-low": this.mixColors(primary, secondary, isDark ? 0.2 : 0.15),
      "--primary-low-mid": this.mixColors(primary, secondary, isDark ? 0.35 : 0.3),
      "--primary-medium": this.mixColors(primary, secondary, isDark ? 0.5 : 0.45),
      "--primary-high": this.mixColors(primary, secondary, isDark ? 0.75 : 0.7),
      "--primary-very-high": this.mixColors(primary, secondary, isDark ? 0.9 : 0.85),

      // Secondary variants
      "--secondary-very-low": isDark ? this.lighten(secondary, 0.03) : this.darken(secondary, 0.02),
      "--secondary-low": isDark ? this.lighten(secondary, 0.07) : this.darken(secondary, 0.05),
      "--secondary-medium": isDark ? this.lighten(secondary, 0.15) : this.darken(secondary, 0.1),
      "--secondary-high": isDark ? this.lighten(secondary, 0.25) : this.darken(secondary, 0.2),
      "--secondary-very-high": isDark ? this.lighten(secondary, 0.35) : this.darken(secondary, 0.3),

      // Tertiary variants
      "--tertiary-very-low": this.mixColors(tertiary, secondary, 0.05),
      "--tertiary-low": this.mixColors(tertiary, secondary, isDark ? 0.15 : 0.1),
      "--tertiary-medium": this.mixColors(tertiary, secondary, isDark ? 0.35 : 0.3),
      "--tertiary-high": this.mixColors(tertiary, primary, 0.3),
      "--tertiary-hover": isDark ? this.lighten(tertiary, 0.1) : this.darken(tertiary, 0.1),

      // Highlight variants
      "--highlight-low": this.mixColors(highlight, secondary, 0.15),
      "--highlight-medium": this.mixColors(highlight, secondary, 0.4),
      "--highlight-high": this.mixColors(highlight, primary, 0.6),

      // Header variants (uses primary/secondary for unified look)
      "--header_primary-very-high": this.mixColors(primary, secondary, 0.85),
      "--header_primary-high": this.mixColors(primary, secondary, 0.7),
      "--header_primary-medium": this.mixColors(primary, secondary, 0.5),
      "--header_primary-low-mid": this.mixColors(primary, secondary, 0.4),
      "--header_primary-low": this.mixColors(primary, secondary, 0.3),
      "--header_primary-very-low": this.mixColors(primary, secondary, 0.15),

      // Common UI colors
      "--danger": "#e45735",
      "--danger-low": isDark ? this.mixColors("#e45735", secondary, 0.15) : this.mixColors("#e45735", secondary, 0.1),
      "--danger-medium": this.mixColors("#e45735", secondary, 0.35),
      "--success": "#009900",
      "--success-low": isDark ? this.mixColors("#009900", secondary, 0.15) : this.mixColors("#009900", secondary, 0.1),
      "--love": "#fa6c8d",
      "--love-low": this.mixColors("#fa6c8d", secondary, 0.15),

      // Horizon-specific: selected and hover states
      "--d-selected": selected,
      "--d-hover": hover,
      "--selected-hover": isDark ? this.lighten(selected, 0.05) : this.darken(selected, 0.05),

      // Sidebar (comprehensive)
      "--d-sidebar-background": secondary,
      "--d-sidebar-highlight-background": selected,
      "--d-sidebar-highlight-hover-background": hover,
      "--d-sidebar-row-hover-background": hover,
      "--d-sidebar-link-color": primary,
      "--d-sidebar-link-icon-color": this.mixColors(primary, secondary, 0.6),
      "--d-sidebar-header-color": this.mixColors(primary, secondary, 0.7),
      "--d-sidebar-header-icon-color": this.mixColors(primary, secondary, 0.5),
      "--d-sidebar-active-color": primary,
      "--d-sidebar-active-background": selected,
      "--d-sidebar-highlight-color": primary,
      "--d-sidebar-border-color": isDark ? this.lighten(secondary, 0.1) : this.darken(secondary, 0.1),
      "--d-sidebar-section-border-color": isDark ? this.lighten(secondary, 0.08) : this.darken(secondary, 0.08),
      "--d-sidebar-suffix-color": this.mixColors(primary, secondary, 0.5),
      "--d-sidebar-prefix-color": this.mixColors(primary, secondary, 0.6),

      // Navigation
      "--d-nav-color": this.mixColors(primary, secondary, 0.7),
      "--d-nav-color--hover": primary,
      "--d-nav-color--active": primary,
      "--d-nav-bg-color--hover": hover,
      "--d-nav-bg-color--active": selected,
      "--d-nav-border-color--active": tertiary,
      "--d-link-color": tertiary,

      // Topic list
      "--d-topic-list-item-background-color": secondary,
      "--d-topic-list-item-background-color--visited": isDark ? this.lighten(secondary, 0.02) : this.darken(secondary, 0.01),
      "--d-topic-list-header-background-color": isDark ? this.lighten(secondary, 0.05) : this.darken(secondary, 0.03),
      "--d-topic-list-header-text-color": this.mixColors(primary, secondary, 0.6),

      // Buttons - default
      "--d-button-default-bg-color": isDark ? this.lighten(secondary, 0.1) : this.darken(secondary, 0.05),
      "--d-button-default-bg-color--hover": isDark ? this.lighten(secondary, 0.15) : this.darken(secondary, 0.1),
      "--d-button-default-text-color": primary,
      "--d-button-default-text-color--hover": primary,
      "--d-button-default-icon-color": this.mixColors(primary, secondary, 0.7),
      "--d-button-default-icon-color--hover": primary,

      // Buttons - primary
      "--d-button-primary-bg-color": tertiary,
      "--d-button-primary-bg-color--hover": isDark ? this.lighten(tertiary, 0.1) : this.darken(tertiary, 0.1),
      "--d-button-primary-text-color": "#ffffff",
      "--d-button-primary-text-color--hover": "#ffffff",
      "--d-button-primary-icon-color": "#ffffff",
      "--d-button-primary-icon-color--hover": "#ffffff",

      // Buttons - flat
      "--d-button-flat-bg-color--hover": hover,
      "--d-button-flat-icon-color": this.mixColors(primary, secondary, 0.6),
      "--d-button-flat-icon-color--hover": primary,

      // Content background
      "--d-content-background": secondary,

      // Input fields
      "--d-input-bg-color": secondary,
      "--d-input-text-color": primary,
      "--d-input-border": isDark ? this.lighten(secondary, 0.2) : this.darken(secondary, 0.15),
      "--input-border-color": isDark ? this.lighten(secondary, 0.2) : this.darken(secondary, 0.15),

      // Tags
      "--d-tag-background-color": isDark ? this.lighten(secondary, 0.1) : this.darken(secondary, 0.05),
      "--tag-text-color": this.mixColors(primary, secondary, 0.7),

      // Misc
      "--d-unread-notification-background": this.mixColors(tertiary, secondary, 0.2),

      // Search box - give it a visible border/background
      "--search-bg": isDark ? this.lighten(secondary, 0.08) : this.darken(secondary, 0.03),
      "--search-border": isDark ? this.lighten(secondary, 0.2) : this.darken(secondary, 0.12),
    };
  }

  applyColors() {
    const colors = this.colors;
    if (colors.length < 6) {
      const existing = document.getElementById("custom-user-colors");
      if (existing) {
        existing.remove();
      }
      return;
    }

    const vars = this.generateColorVariables(colors);

    let css = ":root {\n";
    for (const [key, value] of Object.entries(vars)) {
      css += `  ${key}: ${value} !important;\n`;
    }
    css += "}";

    let style = document.getElementById("custom-user-colors");
    if (!style) {
      style = document.createElement("style");
      style.id = "custom-user-colors";
      document.head.appendChild(style);
    }
    style.textContent = css;
  }

  <template>
    <div class="control-group custom-colors-settings">
      <label class="control-label">{{i18n "custom_colors.title"}}</label>
      <div class="controls">
        <p class="instructions">{{i18n "custom_colors.instructions"}}</p>
        <input
          type="text"
          class="custom-colors-input"
          placeholder="#1a1a2e #16213e #0f3460 #e94560 #ffffff #ffd700"
          value={{this.colorString}}
          {{on "input" this.updateColorString}}
        />

        {{#if this.colors.length}}
          <div class="color-preview">
            {{#each this.colors as |color index|}}
              <div class="color-swatch" style="background-color: {{color}}">
                <span class="color-label">
                  {{#if (get this.colorLabels index)}}
                    {{get this.colorLabels index}}
                  {{else}}
                    {{color}}
                  {{/if}}
                </span>
              </div>
            {{/each}}
          </div>
        {{/if}}

        <div class="custom-colors-actions">
          <button
            type="button"
            class="btn btn-primary"
            disabled={{this.saving}}
            {{on "click" this.saveColors}}
          >
            {{#if this.saving}}
              {{i18n "saving"}}
            {{else if this.saved}}
              {{i18n "saved"}}
            {{else}}
              {{i18n "save"}}
            {{/if}}
          </button>

          {{#if this.colorString}}
            <button
              type="button"
              class="btn btn-default"
              {{on "click" this.clearColors}}
            >
              {{i18n "custom_colors.clear"}}
            </button>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
