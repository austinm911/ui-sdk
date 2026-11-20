"use strong"
import {
  Carousel,
  CarouselContent,
  CarouselIndicator,
  CarouselIndicatorGroup,
  CarouselItem,
  CarouselNext,
  CarouselPlayToggle,
  CarouselPrevious,
  CarouselViewport,
  createCarouselController,
  type CarouselController,
  type CarouselPlayToggleState,
} from "@ui-sdk/octane/carousel"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { slideBasis, slideCount, type Variant } from "./variants"

const slides = Array.from({ length: slideCount }, (_, index) => index + 1)

function Controls({
  variant,
  controller,
}: {
  variant: Variant
  controller?: CarouselController
}) {
  return (
    <div className={classes.controls}>
      <CarouselPrevious className={classes.step} controller={controller}>
        {"Previous"}
      </CarouselPrevious>
      <CarouselNext className={classes.step} controller={controller}>
        {"Next"}
      </CarouselNext>
      @if (variant.toggle) {
        <CarouselPlayToggle className={classes.toggle} controller={controller}>
          {(state: CarouselPlayToggleState) =>
            state.playing ? "Stop rotation" : "Start rotation"
          }
        </CarouselPlayToggle>
      }
      <CarouselIndicatorGroup
        className={classes.indicators}
        aria-label="Choose a slide"
        controller={controller}
      >
        @for (const slide of slides; key slide) {
          <CarouselIndicator
            className={classes.indicator}
            aria-label={`Slide ${slide}`}
            render={
              variant.links
                ? (props) => (
                    <a href={`#kitchen-${variant.id}-${slide}`} {...props} />
                  )
                : undefined
            }
          />
        }
      </CarouselIndicatorGroup>
    </div>
  )
}

function VariantCarousel({ variant, env }: { variant: Variant; env: Env }) {
  const [page, setPage] = React.useState(1)
  const controller = React.useInitialValue(() =>
    variant.controller || variant.outside
      ? createCarouselController()
      : undefined
  )
  React.useEffect(() => {
    if (!controller || !variant.controller) {
      return
    }
    env.controls([
      ["next()", () => controller.next()],
      ["previous()", () => controller.previous()],
      ["setPage(4)", () => controller.setPage(4)],
      ["play()", () => controller.play()],
      ["pause()", () => controller.pause()],
      ["getPage()", () => controller.getPage()],
      ["getPageCount()", () => controller.getPageCount()],
    ])
  })
  // Each slide with its basis, which depends on its position.
  const items = slides.map((slide, index) => ({
    slide,
    basis: slideBasis(variant, index),
  }))
  return (
    <>
      <Carousel
        className={classes.root}
        aria-label={variant.title}
        {...variant.options}
        {...(variant.controlled && { page })}
        controller={controller}
        onPageChange={(next, details) => {
          if (variant.cancel) {
            return details.cancel()
          }
          if (variant.controlled) {
            setPage(next)
          }
          env.log(`pageChange ${next} (${details.reason}, ${details.source})`)
        }}
        onPlayingChange={(playing, details) =>
          env.log(`playingChange ${playing} (${details.reason})`)
        }
      >
        <CarouselViewport className={classes.viewport}>
          <CarouselContent className={classes.content}>
            @for (const item of items; key item.slide) {
              <CarouselItem
                className={classes.slide}
                style={{ flexBasis: item.basis }}
              >
                {item.slide}
              </CarouselItem>
            }
          </CarouselContent>
        </CarouselViewport>
        @if (!variant.outside) {
          <Controls variant={variant} />
        }
      </Carousel>
      @if (variant.outside) {
        <Controls variant={variant} controller={controller} />
      }
    </>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantCarousel variant={variant} env={env} />)
  )
}

export { mount }
