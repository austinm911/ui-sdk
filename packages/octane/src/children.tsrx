"use strong"
// Where a root's content part says it's there. Octane can't read a part out
// of the children, so the part tells its root when it mounts, before the page
// paints, even inside a component of the app's own, like a styled
// `SelectContent`.
import * as React from "octane"

const PlacedContext = React.createContext<(() => () => void) | null>(null)

// How many content parts are placed. A store, so a part mounting re-renders
// its root through useSyncExternalStore, not a state update from an effect.
function placedStore() {
  let count = 0
  const listeners = new Set<() => void>()
  const notify = () => listeners.forEach((listener) => listener())
  return {
    subscribe(listener: () => void) {
      listeners.add(listener)
      return () => {
        listeners.delete(listener)
      }
    },
    count: () => count,
    register() {
      count++
      notify()
      return () => {
        count--
        notify()
      }
    },
  }
}

/**
 * For a root that renders its own content part when the app places none:
 * whether one is placed, and the value of the provider its children go in.
 * Its own part goes in `<Placed value={null}>`, so it doesn't count. `wanted`
 * is whether the root would render its own part now. Only then do placed
 * parts register, so a root with no items to show renders once.
 */
function usePlacedContent(wanted: boolean) {
  const store = React.useInitialValue(placedStore)
  const count = React.useSyncExternalStore(store.subscribe, store.count)
  return [count > 0, wanted ? store.register : null] as const
}

const Placed = PlacedContext

/** Called by a content part, so its root doesn't render one of its own as well. */
function usePlaceContent() {
  const register = React.useContext(PlacedContext)
  React.useLayoutEffect(() => register?.())
}

export { Placed, usePlaceContent, usePlacedContent }
