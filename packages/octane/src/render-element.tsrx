"use strong"
// Renders an element with no primitive behind it, and merges props and refs.
import { isChildrenBlock } from "octane"
import type * as Octane from "octane"

/**
 * Later props win, except where they combine: className, style and ref, and
 * event handlers, where the later one runs first and can call
 * preventDefault() to skip the earlier. Undefined never replaces a value.
 * @stable
 */
function mergeProps(...sources: Record<string, any>[]) {
  const result: Record<string, any> = {}
  for (const source of sources) {
    for (const key in source) {
      const value = source[key]
      if (value === undefined) {
        continue
      }
      const earlier = result[key]
      if (earlier === undefined) {
        result[key] = value
      } else if (key === "className" && earlier) {
        result.className = `${earlier} ${value}`
      } else if (key === "style" && earlier) {
        result.style = mergeStyles(earlier, value)
      } else if (key === "ref" && earlier) {
        result.ref = mergeRefs(earlier, value)
      } else if (
        /^on[A-Z]/.test(key) &&
        typeof earlier === "function" &&
        typeof value === "function"
      ) {
        result[key] = (event: Event, ...rest: unknown[]) => {
          value(event, ...rest)
          if (!(event as Event | undefined)?.defaultPrevented) {
            earlier(event, ...rest)
          }
        }
      } else {
        result[key] = value
      }
    }
  }
  return result
}

// Styles merge, and a function of the part's state stays a function, so a
// part's own inline styles never drop a user's style function.
function mergeStyles(earlier: unknown, later: unknown) {
  if (typeof earlier !== "function" && typeof later !== "function") {
    return { ...(earlier as object), ...(later as object) }
  }
  const resolve = (style: unknown, state: unknown) =>
    typeof style === "function" ? style(state) : style
  return (state: unknown) => ({
    ...resolve(earlier, state),
    ...resolve(later, state),
  })
}

const mergedRefs = new WeakMap<
  object,
  WeakMap<object, (el: unknown) => () => void>
>()

function setRef(ref: Octane.Ref<unknown>, el: unknown) {
  if (typeof ref === "function") {
    return ref(el)
  }
  if (ref) {
    ;(ref as { current: unknown }).current = el
  }
}

/**
 * Stable for the same pair of refs, so Octane does not detach and reattach.
 * Octane runs the cleanup it returns instead of passing null, so each ref's
 * own cleanup runs, and a ref without one gets null.
 */
function mergeRefs(a: Octane.Ref<unknown>, b: Octane.Ref<unknown>) {
  if (!a || !b) {
    return a ?? b
  }
  let inner = mergedRefs.get(a)
  if (!inner) {
    mergedRefs.set(a, (inner = new WeakMap()))
  }
  let merged = inner.get(b)
  if (!merged) {
    merged = (el: unknown) => {
      const cleanups = [setRef(a, el), setRef(b, el)]
      return () =>
        cleanups.forEach((cleanup, index) =>
          typeof cleanup === "function"
            ? cleanup()
            : setRef(index ? b : a, null)
        )
    }
    inner.set(b, merged)
  }
  return merged
}

/**
 * A part's `render` prop: a function of the part's props and state that
 * returns the element to render, which spreads the props onto it.
 * @stable
 */
type RenderProp<State = {}> = (
  props: Record<string, any>,
  state: State
) => unknown

// Octane compiles template children into a render function. A function a
// part should call with its state is any other function.
function isStateFunction(value: unknown): value is (state: never) => unknown {
  return typeof value === "function" && !isChildrenBlock(value)
}

/**
 * Renders an element with no primitive behind it that takes a `render` prop,
 * like a wrapper of your own: the tag, or what `render` returns given the
 * props. Class name, style and children functions resolve against `state`.
 * Parts of a primitive use `createParts` or `usePart`.
 *
 * @example
 * function Card({ render, ...props }: PartProps<"div">) {
 *   return renderElement("div", { ...props, "data-card": "" }, render)
 * }
 * @stable
 */
function renderElement<State>(
  tag: string,
  props: Record<string, any>,
  render?: RenderProp<State>,
  state: State = {} as State
) {
  if (isStateFunction(props.className)) {
    props = { ...props, className: props.className(state as never) }
  }
  if (isStateFunction(props.style)) {
    props = { ...props, style: props.style(state as never) }
  }
  if (isStateFunction(props.children)) {
    props = { ...props, children: props.children(state as never) }
  }
  if (render) {
    return <>{render(props, state)}</>
  }
  const Tag = tag
  return <Tag {...props} />
}

export {
  isStateFunction,
  mergeProps,
  mergeRefs,
  renderElement,
  type RenderProp,
}
