To document the blur effect and the necessary changes for your widgets, you need to coordinate the **Hyprland Layer Rules** with your **EWW Stylesheet**. This ensures the compositor (Hyprland) applies the effect and the widget (EWW) allows it to be visible.

---

### 1. Hyprland Configuration (Layer Rules)

In Hyprland versions >= 0.53, you must target the **namespace** of the layer surface using the `match:` syntax. Use these rules to enable blur and remove the "translucent box" artifact:

* **`blur`**: Activates the Gaussian blur behind the specified namespace.
* **`ignore_zero`**: Prevents the blur from rendering on fully transparent pixels, which keeps rounded corners sharp.
* **`ignore_alpha [value]`**: Essential for removing the "ghost box." It tells the compositor not to blur any area with an opacity lower than the specified threshold (e.g., **0.5**).

**The Correct Syntax:**

```hyprlang
layerrule = match:namespace ^(eww)$, blur
layerrule = match:namespace ^(eww)$, ignore_zero
layerrule = match:namespace ^(eww)$, ignore_alpha 0.5

```

---

### 2. EWW Stylesheet Changes (CSS/SCSS)

The blur effect is applied *behind* your window. If your widget has a solid background color (e.g., `#1e1e2e`), you will not see the blur. You must change your background to use **RGBA** values.

* **Transparency**: Change background hex codes to `rgba(r, g, b, a)` where `a` is the decimal opacity (e.g., `0.6` for 60%).
* **Container Logic**: Ensure outer "reveal" containers are set to `background-color: transparent` so they don't trigger unnecessary blur areas.

**Example Widget Change:**

```scss
/* Target the specific widget class */
.control-center {
    /* Use rgba to let the Hyprland blur show through */
    background-color: rgba(30, 30, 46, 0.6) !important; 
    border-radius: 15px; 
    border: 1px solid rgba(255, 255, 255, 0.1); /* Optional: adds a 'glass' edge */
}

```

---

### 3. Widget Structure (Yuck)

To prevent the "big box" from appearing during transitions, ensure your window geometry and widget alignment are tight.

* **Namespace**: Ensure the `:namespace` in your `defwindow` matches the name used in your Hyprland rules (e.g., `"eww"`).
* **Alignment**: Use `:halign` and `:valign` on the inner boxes to keep the content from stretching the layer surface to full-screen dimensions unnecessarily.

**Example Window Definition:**

```yuck
(defwindow control_center
    :monitor 0
    :stacking "overlay"
    :namespace "eww"  ;; This must match the layerrule
    :geometry (geometry :anchor "bottom right" :width "2px" :height "2px")
    (control_center_widget)
)

```

Would you like me to help you write a specific **SCSS mixin** for this so you can apply the "Glass/Blur" look to all your widgets at once?