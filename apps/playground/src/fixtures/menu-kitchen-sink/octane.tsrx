"use strong"
import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuGroup,
  MenuGroupLabel,
  MenuItem,
  MenuItemIndicator,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator,
  MenuSub,
  MenuSubContent,
  MenuSubTrigger,
  MenuTrigger,
  type MenuData,
  type MenuDataItem,
} from "@ui-sdk/octane/menu"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import type { Variant } from "./variants"

// Separators, groups and submenus have nothing that names them, so each
// keeps the id it first got.
const entryIds = new WeakMap<object, number>()
const entryCount = { last: 0 }

function entryKey(item: MenuDataItem) {
  switch (item.type) {
    case undefined:
    case "item":
    case "checkbox":
      return `item-${item.value}`
    case "radio-group":
      return `radio-group-${item.name}`
  }
  let id = entryIds.get(item)
  if (id === undefined) {
    entryIds.set(item, (id = ++entryCount.last))
  }
  return `${item.type}-${id}`
}

// The variant's items as parts, the same way at every level.
function Entries({ items, popup }: { items: MenuData; popup: string }) @{
  const rows = items.map((entry) => {
    const item: MenuDataItem =
      typeof entry === "string" ? { value: entry, label: entry } : entry
    return { item, key: entryKey(item) }
  })
  @for (const row of rows; key row.key) {
    <Entry item={row.item} popup={popup} />
  }
}

function Entry({ item, popup }: { item: MenuDataItem; popup: string }) {
  switch (item.type) {
    case undefined:
    case "item":
      return (
        <MenuItem
          className={classes.item}
          value={item.value}
          disabled={item.disabled}
          shortcut={item.shortcut}
          closeOnSelect={item.closeOnSelect}
          destructive={item.destructive}
        >
          {item.label}
        </MenuItem>
      )
    case "separator":
      return <MenuSeparator className={classes.separator} />
    case "group":
      return (
        <MenuGroup>
          @if (item.label) {
            <MenuGroupLabel className={classes.groupLabel}>
              {item.label}
            </MenuGroupLabel>
          }
          <Entries items={item.items} popup={popup} />
        </MenuGroup>
      )
    case "checkbox":
      return (
        <MenuCheckboxItem
          className={classes.item}
          value={item.value}
          disabled={item.disabled}
          checked={item.checked}
          defaultChecked={item.defaultChecked}
          closeOnSelect={item.closeOnSelect}
        >
          <MenuItemIndicator className={classes.indicator}>
            {"✓"}
          </MenuItemIndicator>
          {item.label}
        </MenuCheckboxItem>
      )
    case "radio-group":
      return (
        <MenuRadioGroup
          name={item.name}
          value={item.value}
          defaultValue={item.defaultValue}
        >
          @if (item.label) {
            <MenuGroupLabel className={classes.groupLabel}>
              {item.label}
            </MenuGroupLabel>
          }
          @for (const radio of item.items; key radio.value) {
            <MenuRadioItem
              className={classes.item}
              value={radio.value}
              disabled={radio.disabled}
            >
              <MenuItemIndicator className={classes.indicator}>
                {"•"}
              </MenuItemIndicator>
              {radio.label}
            </MenuRadioItem>
          }
        </MenuRadioGroup>
      )
    case "submenu":
      return (
        <MenuSub>
          <MenuSubTrigger className={classes.item} disabled={item.disabled}>
            {item.label}
            <span aria-hidden className={classes.chevron}>
              {"›"}
            </span>
          </MenuSubTrigger>
          <MenuSubContent className={popup}>
            <Entries items={item.items} popup={popup} />
          </MenuSubContent>
        </MenuSub>
      )
  }
}

function VariantMenu({ variant, env }: { variant: Variant; env: Env }) {
  const [open, setOpen] = React.useState(false)
  const popup = classes.content(variant.animation)
  const shared = {
    ...variant.options,
    controller: env.controller,
    container: env.container,
    ...(variant.controlled && { open }),
    onOpenChange: (next: boolean, details: { reason: string }) => {
      if (variant.controlled) {
        setOpen(next)
      }
      env.log(`openChange ${next} (${details.reason})`)
    },
    onAction: (value: string) => env.log(`action ${value}`),
  }

  // A data menu also knows its items, and reports its checkbox items and radio groups.
  return (
    <div className="flex items-center gap-3">
      <Menu
        {...shared}
        items={variant.mode === "data" ? variant.items : undefined}
      >
        <MenuTrigger className={classes.trigger}>
          {variant.trigger ?? "Open"}
        </MenuTrigger>
        <MenuContent className={popup} {...variant.content}>
          <Entries items={variant.items} popup={popup} />
        </MenuContent>
      </Menu>
      @if (variant.controlled) {
        <label className="flex items-center gap-1.5 text-xs text-neutral-600">
          <input
            type="checkbox"
            checked={open}
            onChange={() => setOpen((was) => !was)}
          />
          {"open"}
        </label>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links between, so it's told React.
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantMenu variant={variant} env={env} />)
  )
}

export { mount }
