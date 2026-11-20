"use strong"
import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@ui-sdk/octane/alert-dialog"
import {
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTitle,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import * as React from "octane"
import { createRoot } from "octane"
import { presentationOption } from "tests/fixtures/presentation.ts"

// Two pages under <Activity>, each inside an element. The profile page's
// popup leaves for the other page while open, the way a link in it would.
// One modal popup, picked with ?popup=dialog|alert-dialog|drawer|popover,
// rendered in place or into ?container=id, and as a sheet with
// ?presentation=sheet where it can be one.
const params = new URLSearchParams(location.search)
const containerId = params.get("container")
const container = containerId ? document.getElementById(containerId) : undefined
const popup = params.get("popup") ?? "dialog"
const presentation = presentationOption()

// A title or close part, which renders its children with a class.
type Part = (props: { className?: string; children?: unknown }) => unknown

// The popup's title, a field to type in, a way to leave the page, and Close.
function Fields({
  Title,
  Close,
  onLeave,
}: {
  Title: Part
  Close: Part
  onLeave: () => void
}) {
  return (
    <>
      <Title className="title">{"Edit profile"}</Title>
      <label className="field">
        {"Name"}
        <input />
      </label>
      <div className="actions">
        <button onClick={onLeave}>{"Leave page"}</button>
        <Close>{"Close"}</Close>
      </div>
    </>
  )
}

function ProfilePage({ onLeave }: { onLeave: () => void }) @{
  @if (popup === "alert-dialog") {
    <AlertDialog container={container}>
      <AlertDialogTrigger>{"Edit profile"}</AlertDialogTrigger>
      <AlertDialogBackdrop className="dialog-backdrop" />
      <AlertDialogContent className="dialog">
        <Fields
          Title={AlertDialogTitle}
          Close={AlertDialogClose}
          onLeave={onLeave}
        />
      </AlertDialogContent>
    </AlertDialog>
  } @else if (popup === "drawer") {
    <Drawer container={container}>
      <DrawerTrigger>{"Edit profile"}</DrawerTrigger>
      <DrawerBackdrop className="dialog-backdrop" />
      <DrawerContent className="drawer">
        <Fields Title={DrawerTitle} Close={DrawerClose} onLeave={onLeave} />
      </DrawerContent>
    </Drawer>
  } @else if (popup === "popover") {
    <Popover container={container} modal {...presentation}>
      <PopoverTrigger>{"Edit profile"}</PopoverTrigger>
      <PopoverContent className="popup">
        <Fields Title={PopoverTitle} Close={PopoverClose} onLeave={onLeave} />
      </PopoverContent>
    </Popover>
  } @else {
    <Dialog container={container} {...presentation}>
      <DialogTrigger>{"Edit profile"}</DialogTrigger>
      <DialogBackdrop className="dialog-backdrop" />
      <DialogContent className="dialog">
        <Fields Title={DialogTitle} Close={DialogClose} onLeave={onLeave} />
      </DialogContent>
    </Dialog>
  }
}

function Fixture() {
  const [page, setPage] = React.useState<"profile" | "other">("profile")
  // Each page goes in as a children prop. Written between the tags, the
  // compiled Activity block reads its holes from a `props` it never declares,
  // and the fixture throws on mount.
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <React.Activity
        mode={page === "profile" ? "visible" : "hidden"}
        children={
          <section>
            <ProfilePage onLeave={() => setPage("other")} />
          </section>
        }
      />
      <React.Activity
        mode={page === "other" ? "visible" : "hidden"}
        children={
          <section>
            <button onClick={() => setPage("profile")}>
              {"Back to profile"}
            </button>
          </section>
        }
      />
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
