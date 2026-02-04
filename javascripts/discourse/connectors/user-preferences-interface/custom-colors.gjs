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

    return {
      "--primary": primary,
      "--secondary": secondary,
      "--tertiary": tertiary,
      "--header_background": headerBg,
      "--header_primary": headerPrimary,
      "--highlight": highlight,
      "--quaternary": tertiary,
      "--primary-very-low": this.mixColors(primary, secondary, 0.1),
      "--primary-low": this.mixColors(primary, secondary, isDark ? 0.2 : 0.15),
      "--primary-low-mid": this.mixColors(primary, secondary, isDark ? 0.35 : 0.3),
      "--primary-medium": this.mixColors(primary, secondary, isDark ? 0.5 : 0.45),
      "--primary-high": this.mixColors(primary, secondary, isDark ? 0.75 : 0.7),
      "--primary-very-high": this.mixColors(primary, secondary, isDark ? 0.9 : 0.85),
      "--secondary-very-low": isDark ? this.lighten(secondary, 0.03) : this.darken(secondary, 0.02),
      "--secondary-low": isDark ? this.lighten(secondary, 0.07) : this.darken(secondary, 0.05),
      "--secondary-medium": isDark ? this.lighten(secondary, 0.15) : this.darken(secondary, 0.1),
      "--secondary-high": isDark ? this.lighten(secondary, 0.25) : this.darken(secondary, 0.2),
      "--secondary-very-high": isDark ? this.lighten(secondary, 0.35) : this.darken(secondary, 0.3),
      "--tertiary-low": this.mixColors(tertiary, secondary, isDark ? 0.15 : 0.1),
      "--tertiary-medium": this.mixColors(tertiary, secondary, isDark ? 0.35 : 0.3),
      "--tertiary-high": this.mixColors(tertiary, primary, 0.3),
      "--tertiary-hover": isDark ? this.lighten(tertiary, 0.1) : this.darken(tertiary, 0.1),
      "--highlight-low": this.mixColors(highlight, secondary, 0.15),
      "--highlight-medium": this.mixColors(highlight, secondary, 0.4),
      "--highlight-high": this.mixColors(highlight, primary, 0.6),
      "--header_primary-very-high": this.mixColors(headerPrimary, headerBg, 0.85),
      "--header_primary-high": this.mixColors(headerPrimary, headerBg, 0.7),
      "--header_primary-medium": this.mixColors(headerPrimary, headerBg, 0.5),
      "--header_primary-low": this.mixColors(headerPrimary, headerBg, 0.3),
      "--header_primary-very-low": this.mixColors(headerPrimary, headerBg, 0.15),
      "--danger": "#e45735",
      "--success": "#009900",
      "--love": "#fa6c8d",
      "--d-sidebar-background": headerBg,
      "--d-sidebar-highlight-background": isDark ? this.lighten(headerBg, 0.08) : this.darken(headerBg, 0.05),
      "--d-sidebar-row-hover-background": isDark ? this.lighten(headerBg, 0.05) : this.darken(headerBg, 0.03),
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
