"use strong"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
} from "@ui-sdk/octane/slider"
import { createRoot } from "octane"
import { countRender, perfSize, perfThumbs } from "tests/fixtures/perf.ts"

// A slider with N thumbs for the counts specs. Every other
// thumb reads its value in its render function, so specs can tell plain
// thumbs' renders from watched ones. The last thumb is a watched one.
const values = perfThumbs(perfSize())
const thumbs = values.map((_, index) => ({ index, watched: index % 2 === 1 }))

function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Slider defaultValue={values} max={1000}>
        <SliderControl className="slider-control is-wide">
          <SliderTrack className="slider-track">
            <SliderIndicator
              className="slider-indicator"
              render={(props) => {
                countRender("indicator")
                return <div {...props} />
              }}
            />
            @for (const thumb of thumbs; key thumb.index) {
              @if (thumb.watched) {
                <SliderThumb
                  index={thumb.index}
                  className="slider-thumb"
                  aria-label={`Thumb ${thumb.index + 1}`}
                  render={(props, state) => {
                    countRender("watched")
                    return <div {...props} data-value={state.thumbValue} />
                  }}
                />
              } @else {
                <SliderThumb
                  index={thumb.index}
                  className="slider-thumb"
                  aria-label={`Thumb ${thumb.index + 1}`}
                  render={(props) => {
                    countRender("plain")
                    return <div {...props} />
                  }}
                />
              }
            }
          </SliderTrack>
        </SliderControl>
      </Slider>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
