"use strong"
import { Avatar, AvatarFallback, AvatarImage } from "@ui-sdk/octane/avatar"
import * as React from "octane"
import { createRoot } from "octane"
import {
  avatarAction,
  avatarFixture,
  type AvatarFixtureItem,
} from "tests/fixtures/avatar.ts"

function FixtureAvatar({
  item,
  ...props
}: Partial<Parameters<typeof Avatar>[0]> & { item: AvatarFixtureItem }) {
  return (
    <Avatar className="avatar" {...props}>
      @if (item.src !== undefined) {
        <AvatarImage
          className="avatar-image"
          src={item.src}
          alt={item.name}
          referrerPolicy={item.referrerPolicy}
          crossOrigin={item.crossOrigin}
        />
      }
      <AvatarFallback className="avatar-fallback" delay={item.delay}>
        {item.initials}
      </AvatarFallback>
    </Avatar>
  )
}

function Fixture() {
  const [action, setAction] = React.useState("")
  const [src, setSrc] = React.useState<string | undefined>(
    avatarFixture.items[0].src
  )
  const [mounts, setMounts] = React.useState(0)
  const [first, ...rest] = avatarFixture.items

  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <FixtureAvatar
        key={mounts}
        item={{ ...first, src }}
        onLoadingStatusChange={(status, details) =>
          setAction(avatarAction(status, details.reason))
        }
      />
      @for (const item of rest; key item.name) {
        <FixtureAvatar item={item} />
      }
      <button onClick={() => setSrc(avatarFixture.nextSrc)}>
        {"Change image"}
      </button>
      <button onClick={() => setSrc(undefined)}>{"Remove image"}</button>
      <button onClick={() => setMounts((count) => count + 1)}>{"Remount"}</button>
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
