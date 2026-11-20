"use strong"
import {
  createScrollAreaController,
  ScrollArea,
  ScrollAreaContent,
  ScrollAreaCorner,
  ScrollAreaScrollbar,
  ScrollAreaScrollToEnd,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import {
  fadeBottom,
  fadeBottomStyle,
  fadeTop,
  fadeTopStyle,
  kitchenSink,
  rootClass,
  variantControls,
  viewportClass,
  type Env,
} from "./shell"
import { fillContent, type Variant } from "./variants"

const style = (css: string) =>
  Object.fromEntries(
    css.split(";").map((declaration) => declaration.split(":"))
  ) as React.CSSProperties

function Scrollbar({
  orientation,
}: {
  orientation: "vertical" | "horizontal"
}) {
  return (
    <ScrollAreaScrollbar
      className={classes.scrollbar}
      orientation={orientation}
    >
      <ScrollAreaThumb className={classes.thumb} />
    </ScrollAreaScrollbar>
  )
}

function VariantScrollArea({ variant, env }: { variant: Variant; env: Env }) {
  const controller = React.useInitialValue(createScrollAreaController)
  const content = React.useRef<HTMLDivElement>(null)
  React.useLayoutEffect(() => {
    const el = content.current!
    // The content is plain DOM, filled once, so every framework shows the same.
    if (!el.childElementCount) {
      fillContent(el, variant)
    }
    variantControls(variant, el, controller, env)
  })
  const { scrollbars } = variant
  return (
    <ScrollArea
      className={rootClass(variant)}
      controller={controller}
      {...variant.options}
    >
      <ScrollAreaViewport className={viewportClass(variant)}>
        <ScrollAreaContent ref={content} className={classes.content} />
      </ScrollAreaViewport>
      @if (variant.fade) {
        <>
          <div className={fadeTop} style={style(fadeTopStyle)} />
          <div className={fadeBottom} style={style(fadeBottomStyle)} />
        </>
      }
      @if (scrollbars === "vertical" || scrollbars === "both") {
        <Scrollbar orientation="vertical" />
      }
      @if (scrollbars === "horizontal" || scrollbars === "both") {
        <Scrollbar orientation="horizontal" />
      }
      @if (scrollbars === "both") {
        <ScrollAreaCorner className={classes.corner} />
      }
      @if (variant.jump) {
        <ScrollAreaScrollToEnd className={classes.jump}>
          {"Jump to latest"}
        </ScrollAreaScrollToEnd>
      }
    </ScrollArea>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantScrollArea variant={variant} env={env} />)
  )
}

export { mount }
