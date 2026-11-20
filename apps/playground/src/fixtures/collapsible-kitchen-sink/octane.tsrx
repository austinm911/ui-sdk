"use strong"
import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { content, tree, type TreeNode, type Variant } from "./variants"

function Grow() {
  const [lines, setLines] = React.useState(1)
  const numbers = Array.from({ length: lines }, (_, index) => index + 1)
  return (
    <>
      @for (const line of numbers; key line) {
        <p>{`Line ${line}`}</p>
      }
      <button
        className={`${classes.button} self-start`}
        onClick={() => setLines((count) => count + 1)}
      >
        {"Add a line"}
      </button>
    </>
  )
}

const longLines = Array.from({ length: 20 }, (_, index) => index + 1)

// What the panel holds.
function Body({ variant }: { variant: Variant }) @{
  @if (variant.body === "long") {
    @for (const line of longLines; key line) {
      <p>{`Line ${line}`}</p>
    }
  } @else if (variant.body === "form") {
    <label className="flex flex-col">
      {content.text}
      <input className={classes.input} defaultValue="Ada" aria-label="Name" />
    </label>
  } @else if (variant.body === "grow") {
    <Grow />
  } @else {
    <>{content.text}</>
  }
}

// A folder is a collapsible holding its children. Files are plain rows.
function Folder({ node, env }: { node: TreeNode; env: Env }) {
  if (!node.children) {
    return <div className={classes.treeFile}>{node.name}</div>
  }
  const children = node.children
  return (
    <Collapsible
      onOpenChange={(open, details) =>
        env.log(`${node.name} openChange ${open} (${details.reason})`)
      }
      onOpenChangeComplete={(open) =>
        env.log(`${node.name} openChangeComplete ${open}`)
      }
    >
      <CollapsibleTrigger className={classes.treeTrigger}>
        <span aria-hidden className={classes.treeChevron}>
          {"▸"}
        </span>
        {`${node.name}/`}
      </CollapsibleTrigger>
      <CollapsiblePanel className={classes.treePanel}>
        @for (const child of children; key child.name) {
          <Folder node={child} env={env} />
        }
      </CollapsiblePanel>
    </Collapsible>
  )
}

const divTrigger = (props: Record<string, any>) => <div {...props} />
const linkTrigger = (props: Record<string, any>) => (
  <a href="#collapsible-link" {...props} />
)
const sectionPanel = (props: Record<string, any>) => <section {...props} />

function VariantCollapsible({ variant, env }: { variant: Variant; env: Env }) {
  const [open, setOpen] = React.useState(
    () => variant.options?.defaultOpen ?? false
  )
  if (variant.body === "tree") {
    return (
      <div className="w-full rounded-lg border border-neutral-200 bg-white p-2">
        <Folder node={tree} env={env} />
      </div>
    )
  }
  const trigger =
    variant.render?.trigger === "div"
      ? divTrigger
      : variant.render?.trigger === "link"
        ? linkTrigger
        : undefined
  return (
    <div className="flex flex-col gap-2">
      <Collapsible
        className={classes.root}
        {...variant.options}
        controller={env.controller}
        {...(variant.controlled && { open })}
        onOpenChange={(next, details) => {
          if (variant.cancel === (next ? "open" : "close")) {
            details.cancel()
            env.log(`openChange ${next} canceled`)
            return
          }
          if (variant.controlled) {
            setOpen(next)
          }
          env.log(`openChange ${next} (${details.reason})`)
        }}
        onOpenChangeComplete={(next) => env.log(`openChangeComplete ${next}`)}
      >
        <CollapsibleTrigger className={classes.trigger} render={trigger}>
          {content.trigger}
          <span aria-hidden className={classes.chevron}>
            {"▾"}
          </span>
        </CollapsibleTrigger>
        <CollapsiblePanel
          className={classes.panel(variant.animation)}
          {...variant.panel}
          render={
            variant.render?.panel === "section" ? sectionPanel : undefined
          }
        >
          <div className={classes.inner}>
            <Body variant={variant} />
          </div>
        </CollapsiblePanel>
      </Collapsible>
      @if (variant.controlled) {
        <div className="flex items-center gap-2 text-xs">
          <code className="text-neutral-500">{`open=${String(open)}`}</code>
          <button className={classes.button} onClick={() => setOpen(true)}>
            {"Open"}
          </button>
          <button className={classes.button} onClick={() => setOpen(false)}>
            {"Close"}
          </button>
          <button
            className={classes.button}
            onClick={() => setOpen((value) => !value)}
          >
            {"Toggle"}
          </button>
        </div>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantCollapsible variant={variant} env={env} />)
  )
}

export { mount }
