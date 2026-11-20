"use strong"
import {
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
import {
  scrollAreaFixture,
  scrollAreaOptions,
} from "tests/fixtures/scroll-area.ts"

const { tags, gallery, short, chat } = scrollAreaFixture

function Scrollbar({
  orientation = "vertical",
}: {
  orientation?: "vertical" | "horizontal"
}) {
  return (
    <ScrollAreaScrollbar
      className="scroll-area-scrollbar"
      orientation={orientation}
    >
      <ScrollAreaThumb className="scroll-area-thumb" />
    </ScrollAreaScrollbar>
  )
}

// Messages are only added or have the last one change, so each keeps the
// number it was added as, which keys it.
type Message = { id: number; text: string; image?: boolean }

function Fixture() {
  const { native, ...options } = React.useInitialValue(scrollAreaOptions)
  const [messages, setMessages] = React.useState<Message[]>(() =>
    chat.messages.map((text, index) => ({ id: index + 1, text }))
  )
  const [imagesLoaded, setImagesLoaded] = React.useState(false)
  return (
    <div className="fixture scroll-fixture">
      <button>{"Before"}</button>
      <ScrollArea className="scroll-area" {...options}>
        <ScrollAreaViewport
          className="scroll-area-viewport"
          role="region"
          aria-label={tags.label}
        >
          <ScrollAreaContent>
            @for (const item of tags.items; key item) {
              <p className="scroll-area-item">{item}</p>
            }
          </ScrollAreaContent>
        </ScrollAreaViewport>
        @if (!native) {
          <Scrollbar />
        }
      </ScrollArea>
      <ScrollArea className="scroll-area is-wide" {...options}>
        <ScrollAreaViewport
          className="scroll-area-viewport"
          role="region"
          aria-label={gallery.label}
        >
          <ScrollAreaContent className="scroll-area-grid">
            @for (const item of gallery.items; key item) {
              <a href={`#${item}`}>{item}</a>
            }
          </ScrollAreaContent>
        </ScrollAreaViewport>
        <Scrollbar />
        <Scrollbar orientation="horizontal" />
        <ScrollAreaCorner className="scroll-area-corner" />
      </ScrollArea>
      <ScrollArea className="scroll-area" {...options}>
        <ScrollAreaViewport
          className="scroll-area-viewport"
          role="region"
          aria-label={short.label}
        >
          <ScrollAreaContent>
            @for (const item of short.items; key item) {
              <p className="scroll-area-item">{item}</p>
            }
          </ScrollAreaContent>
        </ScrollAreaViewport>
        <Scrollbar />
      </ScrollArea>
      <ScrollArea className="scroll-area is-chat" stickToEnd {...options}>
        <ScrollAreaViewport
          className="scroll-area-viewport"
          role="region"
          aria-label={chat.label}
        >
          <ScrollAreaContent>
            @for (const message of messages; key message.id) {
              <p className="scroll-area-message">
                {message.text}
                @if (message.image) {
                  <span
                    role="img"
                    aria-label="Image"
                    style={{
                      display: "block",
                      height: imagesLoaded ? chat.imageHeight : 0,
                    }}
                  />
                }
              </p>
            }
          </ScrollAreaContent>
        </ScrollAreaViewport>
        <Scrollbar />
        <ScrollAreaScrollToEnd className="scroll-area-end">
          {chat.jump}
        </ScrollAreaScrollToEnd>
      </ScrollArea>
      <button
        onClick={() =>
          setMessages((current) => [
            ...current,
            { id: current.length + 1, text: `Message ${current.length + 1}` },
          ])
        }
      >
        {"Add message"}
      </button>
      <button
        onClick={() =>
          setMessages((current) => [
            ...current.slice(0, -1),
            {
              ...current[current.length - 1],
              text: current[current.length - 1].text + chat.streamed,
            },
          ])
        }
      >
        {"Stream"}
      </button>
      <button
        onClick={() =>
          setMessages((current) => [
            ...current,
            {
              id: current.length + 1,
              text: `Message ${current.length + 1}`,
              image: true,
            },
          ])
        }
      >
        {"Add image"}
      </button>
      <button onClick={() => setImagesLoaded(true)}>{"Load images"}</button>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action" />
      <div className="scroll-fixture-spacer" />
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
