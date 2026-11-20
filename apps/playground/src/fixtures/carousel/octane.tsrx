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
  type CarouselPlayToggleState,
} from "@ui-sdk/octane/carousel"
import * as React from "octane"
import { createRoot } from "octane"
import { carouselFixture, carouselOptions } from "tests/fixtures/carousel.ts"

const controller = createCarouselController()
// Each slide with its page number.
const slides = carouselFixture.slides.map((slide, index) => ({
  ...slide,
  page: index + 1,
}))

function Fixture() {
  const [action, setAction] = React.useState("")
  const [reason, setReason] = React.useState("")
  const [rested, setRested] = React.useState("")
  const { perView, cancel, playToggle, controlled, options } =
    React.useInitialValue(carouselOptions)
  const [page, setPage] = React.useState(1)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Carousel
        className="carousel"
        aria-label={carouselFixture.label}
        style={{ "--per-view": perView } as React.CSSProperties}
        controller={controller}
        {...options}
        {...(controlled && { page })}
        onPageChange={(page, details) => {
          if (page === cancel) {
            return details.cancel()
          }
          if (controlled) {
            setPage(page)
          }
          setAction(String(page))
          setReason(details.reason)
        }}
        onPageChangeComplete={(page) => setRested(String(page))}
      >
        @if (playToggle) {
          <CarouselPlayToggle className="carousel-toggle">
            {(state: CarouselPlayToggleState) =>
              state.playing ? carouselFixture.stop : carouselFixture.start
            }
          </CarouselPlayToggle>
        }
        <CarouselViewport className="carousel-viewport">
          <CarouselContent className="carousel-content">
            @for (const slide of slides; key slide.title) {
              <CarouselItem className="carousel-slide">
                <p>{slide.title}</p>
                <a href={`?product=${slide.page}`}>{slide.link}</a>
                @if (slide.page === 3) {
                  <label>
                    {` ${carouselFixture.field} `}
                    <input />
                  </label>
                }
              </CarouselItem>
            }
          </CarouselContent>
        </CarouselViewport>
        <div className="carousel-controls">
          <CarouselPrevious className="carousel-step">
            {carouselFixture.previous}
          </CarouselPrevious>
          <CarouselNext className="carousel-step">
            {carouselFixture.next}
          </CarouselNext>
        </div>
        <CarouselIndicatorGroup
          className="carousel-controls"
          aria-label={carouselFixture.indicators}
        >
          @for (const slide of slides; key slide.title) {
            <CarouselIndicator
              className="carousel-indicator"
              aria-label={carouselFixture.indicator(slide.page)}
            >
              {slide.page}
            </CarouselIndicator>
          }
        </CarouselIndicatorGroup>
      </Carousel>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output aria-label="Last reason">{reason}</output>
      <output aria-label="Rested on">{rested}</output>
      <button onClick={() => controller.setPage(4)}>{"Show page 4"}</button>
      @if (controlled) {
        <button onClick={() => setPage(3)}>{"Show page 3 by prop"}</button>
      }
      <CarouselNext controller={controller}>{"Next from outside"}</CarouselNext>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
