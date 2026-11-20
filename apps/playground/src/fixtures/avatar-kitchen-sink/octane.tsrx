"use strong"
import {
  Avatar,
  AvatarFallback,
  AvatarImage,
  type AvatarState,
} from "@ui-sdk/octane/avatar"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import {
  images,
  initialSource,
  sourceControls,
  statusMessage,
  type Person,
  type Source,
  type Variant,
} from "./variants"

const loadingStatus = (state: AvatarState) => state.loadingStatus

function VariantAvatar({
  variant,
  person,
  index,
  env,
}: {
  variant: Variant
  person: Person
  index: number
  env: Env
}) {
  const [source, setSource] = React.useState<Source>(() =>
    initialSource(variant, person, index)
  )
  const isFirst = index === 0
  React.useEffect(() => {
    if (!isFirst || !variant.arrivesAfter || !person.image) {
      return
    }
    const timer = setTimeout(
      () => setSource(images[person.image!]),
      variant.arrivesAfter
    )
    return () => clearTimeout(timer)
  })
  React.useEffect(() => {
    if (isFirst && variant.sources) {
      env.controls(
        sourceControls.map(([label, next]) => [
          label,
          () => void setSource(next),
        ])
      )
    }
  })

  const imageProps = {
    className: variant.render === "image" ? classes.customImage : classes.image,
    src: source ?? undefined,
    alt: person.name,
    ...variant.imageProps,
  }
  return (
    <Avatar
      className={`${classes.avatar} ${classes.sizes[variant.size ?? "md"]}`}
      debug={variant.debug}
      render={
        variant.render === "root"
          ? (props, state) => (
              <div {...props} title={`Status: ${state.loadingStatus}`} />
            )
          : undefined
      }
      onLoadingStatusChange={(status, details) =>
        env.log(statusMessage(person, status, details.reason))
      }
    >
      @if (source !== undefined) {
        <AvatarImage
          {...imageProps}
          render={
            variant.render === "image"
              ? (props) => <img {...props} data-custom="" />
              : undefined
          }
        />
      }
      <AvatarFallback
        className={classes.fallback}
        delay={variant.delay}
        children={
          variant.render === "fallback" ? loadingStatus : person.initials
        }
      />
    </Avatar>
  )
}

function VariantAvatars({ variant, env }: { variant: Variant; env: Env }) {
  // Each avatar's position, which picks its first source.
  const people = variant.people.map((person, index) => ({ person, index }))
  const avatars = (
    <>
      @for (const { person, index } of people; key person.name) {
        <VariantAvatar
          variant={variant}
          person={person}
          index={index}
          env={env}
        />
      }
    </>
  )
  return variant.people.length > 1 ? (
    <div className={classes.group}>{avatars}</div>
  ) : (
    avatars
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantAvatars variant={variant} env={env} />)
  )
}

export { mount }
