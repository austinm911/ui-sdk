"use strong"
import {
  rating,
  ratingItemValues,
  type RatingController,
  type RatingItemState,
  type RatingOptions,
  type RatingState,
} from "@ui-sdk/core/rating"
import * as React from "octane"
import { controlRender, FieldContext, useJoinField } from "./field-context.tsrx"
import { isStateFunction } from "./render-element.tsrx"
import { usePart, usePrimitive, type PartProps } from "./use-primitive.tsrx"

const ItemContext = React.createContext<{ index: number; step: number } | null>(
  null
)

/**
 * A score picked from a row of stars, a radio per star or half star, with a
 * preview while a pointer moves over them. Its children render once per star.
 * @experimental
 */
function Rating({
  value,
  defaultValue,
  onValueChange,
  max = 5,
  step = 1,
  deselectable,
  disabled,
  readOnly,
  required,
  name,
  form,
  loop,
  getValueLabel,
  controller,
  debug,
  render,
  children,
  ...props
}: RatingOptions &
  Omit<
    PartProps<"div", RatingState>,
    "defaultValue" | "onChange" | "onSelect" | "onInput" | "children"
  > & {
    children?: unknown
  }) {
  const field = useJoinField(React.useContext(FieldContext))
  const control = usePrimitive(rating, {
    value,
    defaultValue,
    onValueChange,
    max,
    step,
    deselectable,
    disabled: disabled || field?.disabled,
    readOnly,
    required,
    name: name ?? field?.name,
    form,
    loop,
    getValueLabel,
    controller: controller as RatingController | undefined,
    debug,
  })
  const stars = <Stars max={max} step={step} star={children} />
  return usePart(
    control,
    "root",
    {},
    { ...props, render: controlRender(field, "div", render), children: stars }
  )
}

// The children once per star, each in its item's context.
function Stars({
  max,
  step,
  star,
}: {
  max: number
  step: number
  star: unknown
}) @{
  const indexes = Array.from({ length: max }, (_, at) => at + 1)
  @for (const index of indexes; key index) {
    <ItemContext value={{ index, step }}>
      @if (star == null) {
        <RatingItem />
      } @else {
        <>{star}</>
      }
    </ItemContext>
  }
}

function RatingRadio({ value }: { value: string }) {
  const radio = usePart(rating, "radio", { value }, {}, "button")
  const input = usePart(rating, "input", { value }, {}, "input")
  return (
    <>
      {radio}
      {input}
    </>
  )
}

// The radios that pick a star's scores, a whole one or its halves.
function RatingRadios({ index, step }: { index: number; step: number }) @{
  const scores = ratingItemValues(index, step)
  @for (const score of scores; key score) {
    <RatingRadio value={String(score)} />
  }
}

/**
 * One star. Put its icon inside: the state says how full it is, and the
 * radios that pick its score sit over it.
 * @experimental
 */
function RatingItem({
  children,
  ...props
}: PartProps<"span", RatingItemState>) {
  const item = React.useContext(ItemContext)
  if (!item) {
    throw new Error("RatingItem must be used inside <Rating>.")
  }
  const radios = <RatingRadios index={item.index} step={item.step} />
  return usePart(
    rating,
    "item",
    { index: item.index },
    {
      ...props,
      children: (state: RatingItemState) => (
        <>
          {isStateFunction(children) ? children(state) : children}
          {radios}
        </>
      ),
    },
    "span"
  )
}

export { createRatingController } from "@ui-sdk/core/rating"
export type {
  RatingApi,
  RatingChangeOptions,
  RatingController,
  RatingItemProps,
  RatingItemState,
  RatingOptions,
  RatingPrimitive,
  RatingState,
  RatingValueChangeReason,
} from "@ui-sdk/core/rating"

export { Rating, RatingItem }
