"use strong"
import {
  Carousel,
  CarouselContent,
  CarouselIndicator,
  CarouselIndicatorGroup,
  CarouselItem,
  CarouselNext,
  CarouselViewport,
} from "@ui-sdk/octane/carousel"
import * as React from "octane"
import { createRoot } from "octane"

const slides = ["One", "Two", "Three"]
// Each slide with its photo number.
const photos = slides.map((slide, index) => ({ slide, photo: index + 1 }))

function Fixture() {
  const [action, setAction] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Carousel
        className="carousel"
        aria-label="Photos"
        onPageChange={(page) => setAction(String(page))}
      >
        <CarouselViewport className="carousel-viewport">
          <CarouselContent>
            @for (const slide of slides; key slide) {
              <CarouselItem
                className={(state) =>
                  `carousel-slide ${state.active ? "is-active" : "is-inactive"}`
                }
              >
                {slide}
              </CarouselItem>
            }
          </CarouselContent>
        </CarouselViewport>
        <CarouselNext
          render={(props, state) => (
            <button {...props}>
              {state.disabled ? "No more photos" : "Next photo"}
            </button>
          )}
        />
        <CarouselIndicatorGroup aria-label="Choose a photo">
          @for (const { slide, photo } of photos; key slide) {
            <CarouselIndicator
              aria-label={`Photo ${photo}`}
              render={(props) => <a href={`#photo-${photo}`} {...props} />}
            >
              {photo}
            </CarouselIndicator>
          }
        </CarouselIndicatorGroup>
      </Carousel>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
