"use strong"
import type { MatchSegment } from "@ui-sdk/core/combobox"
import * as React from "octane"
import { isStateFunction } from "./render-element.tsrx"

// An item's text with the parts that matched in `<mark>`, for the list
// components' item text parts.
function markSegments(segments: MatchSegment[]) {
  return (
    <>
      @for (const { text, match } of segments) {
        @if (match) {
          <mark>{text}</mark>
        } @else {
          <>{text}</>
        }
      }
    </>
  )
}

type ReadText = { key: string; text: string | undefined }

// The text read from an item text part's content, for the item it was read for.
function readTextStore(initialKey: string) {
  let read: ReadText = { key: initialKey, text: undefined }
  let key = initialKey
  const listeners = new Set<() => void>()
  const set = (text: string | undefined) => {
    if (read.key !== key || read.text !== text) {
      read = { key, text }
      listeners.forEach((listener) => listener())
    }
  }
  return {
    subscribe(listener: () => void) {
      listeners.add(listener)
      return () => {
        listeners.delete(listener)
      }
    },
    get: () => read,
    setKey(next: string) {
      key = next
    },
    // Reads the content once it's in the page, and again as it changes.
    // Marked text reads as the text it marks, so it changes nothing.
    attach(el: HTMLElement | null) {
      if (!el) {
        return
      }
      const readContent = () => {
        const text = (el.textContent ?? "").replace(/\s+/g, " ").trim()
        if (read.key === key && read.text === text) {
          return
        }
        const nodes = [...el.childNodes]
        set(
          nodes.some((node) => node.nodeType === Node.ELEMENT_NODE)
            ? undefined
            : text
        )
      }
      readContent()
      const observer = new MutationObserver(readContent)
      observer.observe(el, {
        childList: true,
        characterData: true,
        subtree: true,
      })
      return () => observer.disconnect()
    },
  }
}

/**
 * The text an item text part marks, and what it renders. Octane compiles
 * content between tags to a render block, which can't be read before it
 * renders, so the text is read from the page once the content is there, as
 * Svelte does. Until then the content renders as it is, and `label` names
 * the item. Content that holds elements stays as it is. Text content shows
 * its matches marked while a search has any.
 */
function useItemText(children: unknown, key: string, label: string) {
  const store = React.useInitialValue(() => readTextStore(key))
  React.useLayoutEffect(() => store.setKey(key))
  const read = React.useSyncExternalStore(store.subscribe, store.get)
  const known = typeof children === "string" ? children : undefined
  // A reused item reads its content again for its new key.
  const text = known ?? (read.key === key ? read.text : undefined)
  const reads = known === undefined && children != null
  const content = (segments: MatchSegment[]) =>
    !reads || (text !== undefined && segments.some((segment) => segment.match))
      ? markSegments(segments)
      : children
  return {
    text: text ?? label,
    ref: reads && !isStateFunction(children) ? store.attach : undefined,
    content,
  }
}

export { markSegments, useItemText }
