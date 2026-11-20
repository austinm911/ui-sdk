"use strong"
import {
  ScrollArea,
  ScrollAreaScrollbar,
  ScrollAreaThumb,
  ScrollAreaViewport,
  type ScrollAreaState,
} from "@ui-sdk/octane/scroll-area"
import { createRoot } from "octane"

const notes = Array.from({ length: 40 }, (_, index) => `Note ${index + 1}`)
const renders = ((window as unknown as { renders: { root: number } }).renders =
  { root: 0 })

// The root rendered as a section, whose content is a function of its state.
// It counts its renders, which only an edge flipping should cause.
function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <ScrollArea
        render={(props) => <section {...props} />}
        className="scroll-area"
      >
        {(state: ScrollAreaState) => {
          renders.root++
          return (
            <>
              <p className="render-status">
                {state.atEnd ? "At end" : "Reading"}
              </p>
              <ScrollAreaViewport
                render={(props) => <article {...props} />}
                className="scroll-area-viewport"
                role="region"
                aria-label="Notes"
              >
                @for (const note of notes; key note) {
                  <p className="scroll-area-item">{note}</p>
                }
              </ScrollAreaViewport>
              <ScrollAreaScrollbar className="scroll-area-scrollbar">
                <ScrollAreaThumb className="scroll-area-thumb" />
              </ScrollAreaScrollbar>
            </>
          )
        }}
      </ScrollArea>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action" />
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
