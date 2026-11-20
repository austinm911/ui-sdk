"use strong"
import {
  NumberInput,
  NumberInputIncrement,
  NumberInputControl,
  type NumberInputButtonState,
} from "@ui-sdk/octane/number-input"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
  SliderValue,
  type SliderState,
  type SliderThumbState,
  type SliderValueState,
} from "@ui-sdk/octane/slider"
import * as React from "octane"
import { createRoot } from "octane"

// Parts rendered as other elements, and from their state. One fixture covers
// Slider and Number Input.
function Fixture() {
  const [action, setAction] = React.useState("")
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Slider
        defaultValue={40}
        onValueChange={(value) => setAction(`brightness:${value}`)}
      >
        <SliderValue className="slider-value">
          {(state: SliderValueState) => `Brightness ${state.text}`}
        </SliderValue>
        <SliderControl className="slider-control">
          <SliderTrack className="slider-track">
            <SliderIndicator
              className={(state: SliderState) =>
                `slider-indicator ${state.dragging ? "is-dragging" : "is-idle"}`
              }
              style={(state: SliderState) => ({ opacity: state.dragging ? 0.5 : 1 })}
            />
            <SliderThumb
              className="slider-thumb"
              aria-label="Brightness"
              render={(props) => <span {...props} />}
            >
              {(state: SliderThumbState) => (
                <span className="thumb-label">{`${state.thumbValue}`}</span>
              )}
            </SliderThumb>
          </SliderTrack>
        </SliderControl>
      </Slider>
      <NumberInput defaultValue={8} max={9} aria-label="Count">
        <NumberInputControl aria-label="Count" />
        <NumberInputIncrement aria-label="Increase count">
          {(state: NumberInputButtonState) =>
            state.disabled ? "At most" : "More"
          }
        </NumberInputIncrement>
      </NumberInput>
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

export { Fixture, mount }
