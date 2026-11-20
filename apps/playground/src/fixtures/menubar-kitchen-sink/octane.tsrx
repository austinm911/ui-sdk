"use strong"
import { createMenubarController, Menubar } from "@ui-sdk/octane/menubar"
import {
  createToolbarController,
  Toolbar,
  ToolbarButton,
  ToolbarGroup,
  ToolbarInput,
  ToolbarLink,
  ToolbarSeparator,
} from "@ui-sdk/octane/toolbar"
import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuGroup,
  MenuItem,
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
import { Input } from "@ui-sdk/octane/input"
import { NumberInput, NumberInputControl } from "@ui-sdk/octane/number-input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import { Toggle, ToggleGroup } from "@ui-sdk/octane/toggle"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { menus, type Variant } from "./variants"

const fonts = ["Sans", "Serif", "Mono"]
const zooms = ["50", "100", "200"]

function ToolbarVariant({ variant, env }: { variant: Variant; env: Env }) {
  const controller = React.useInitialValue(() =>
    variant.controller ? createToolbarController() : undefined
  )
  React.useEffect(() => {
    if (controller) {
      env.controls([["focus()", () => controller.focus()]])
    }
  })
  const log = (message: string) => () => env.log(message)
  return (
    <Toolbar
      className={classes.bar}
      aria-label={variant.title}
      controller={controller}
      {...variant.options}
    >
      @if (variant.content === "basic") {
        <>
          <ToggleGroup
            className={classes.group}
            aria-label="Style"
            multiple
            onValueChange={(value) => env.log(`style [${value}]`)}
          >
            <Toggle className={classes.item} value="bold">
              {"Bold"}
            </Toggle>
            <Toggle className={classes.item} value="italic">
              {"Italic"}
            </Toggle>
          </ToggleGroup>
          <ToolbarSeparator className={classes.separator} />
          <ToolbarButton className={classes.item} onClick={log("undo")}>
            {"Undo"}
          </ToolbarButton>
          <ToolbarButton
            className={classes.item}
            disabled
            focusableWhenDisabled={!variant.skipDisabled}
            onClick={log("redo")}
          >
            {"Redo"}
          </ToolbarButton>
          <ToolbarLink className={classes.item} href="#kitchen-sink-help">
            {"Help"}
          </ToolbarLink>
        </>
      }
      @if (variant.content === "composed") {
        <>
          <Menu onAction={(value) => env.log(`font ${value}`)}>
            <ToolbarButton
              className={classes.item}
              render={(props) => <MenuTrigger {...props} />}
            >
              {"Font"}
            </ToolbarButton>
            <MenuContent className={classes.popup}>
              @for (const font of fonts; key font) {
                <MenuItem className={classes.menuItem} value={font}>
                  {font}
                </MenuItem>
              }
            </MenuContent>
          </Menu>
          <Select
            defaultValue="100"
            onValueChange={(value) => env.log(`zoom ${value}`)}
          >
            <ToolbarButton
              className={classes.item}
              aria-label="Zoom"
              render={(props) => <SelectTrigger {...props} />}
            >
              <SelectValue />
            </ToolbarButton>
            <SelectContent className={classes.popup}>
              @for (const zoom of zooms; key zoom) {
                <SelectItem className={classes.menuItem} value={zoom}>
                  {`${zoom}%`}
                </SelectItem>
              }
            </SelectContent>
          </Select>
          <NumberInput
            defaultValue={14}
            onValueChange={(value) => env.log(`size ${value}`)}
          >
            <ToolbarInput
              className={classes.input}
              render={(props) => (
                <NumberInputControl {...props} aria-label="Size" />
              )}
            />
          </NumberInput>
          <ToolbarInput
            className={classes.input}
            render={(props) => (
              <Input {...props} aria-label="Find" placeholder="Find" />
            )}
          />
        </>
      }
      @if (variant.content === "groups") {
        <>
          <ToolbarGroup className={classes.group} aria-label="Clipboard">
            <ToolbarButton className={classes.item} onClick={log("cut")}>
              {"Cut"}
            </ToolbarButton>
            <ToolbarButton className={classes.item} onClick={log("copy")}>
              {"Copy"}
            </ToolbarButton>
          </ToolbarGroup>
          <ToolbarSeparator className={classes.separator} />
          <ToolbarGroup className={classes.group} aria-label="History" disabled>
            <ToolbarButton className={classes.item} onClick={log("undo")}>
              {"Undo"}
            </ToolbarButton>
            <ToolbarButton className={classes.item} onClick={log("redo")}>
              {"Redo"}
            </ToolbarButton>
          </ToolbarGroup>
          <Toggle
            className={classes.item}
            onPressedChange={(pressed) => env.log(`wrap ${pressed}`)}
          >
            {"Wrap"}
          </Toggle>
        </>
      }
    </Toolbar>
  )
}

const { file, edit, view, profiles } = menus

// The same menus as data, for the data variant.
const data: MenuData[] = [
  [
    ...file.items,
    {
      type: "submenu",
      label: "Share",
      items: file.share.map((label) => ({ value: label, label })),
    },
  ],
  edit.items!,
  view.checkboxes.map((item) => ({ type: "checkbox" as const, ...item })),
  [
    {
      type: "radio-group",
      name: "profile",
      defaultValue: "Benoit",
      items: profiles.radios.map((label) => ({ value: label, label })),
    },
  ],
]

// The data menus, each with the data it renders.
const dataMenus = [file, edit, view, profiles].map((menu, index) => ({
  trigger: menu.trigger,
  items: data[index]!,
}))

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

// A data menu's items as parts, the same way at every level.
function Entries({ items }: { items: MenuData }) @{
  const rows = items.map((entry) => {
    const item: MenuDataItem =
      typeof entry === "string" ? { value: entry, label: entry } : entry
    return { item, key: entryKey(item) }
  })
  @for (const row of rows; key row.key) {
    <Entry item={row.item} />
  }
}

function Entry({ item }: { item: MenuDataItem }) {
  switch (item.type) {
    case undefined:
    case "item":
      return (
        <MenuItem
          className={classes.menuItem}
          value={item.value}
          shortcut={item.shortcut}
          disabled={item.disabled}
        >
          {item.label}
        </MenuItem>
      )
    case "separator":
      return <MenuSeparator className={classes.separator} />
    case "group":
      return (
        <MenuGroup>
          <Entries items={item.items} />
        </MenuGroup>
      )
    case "checkbox":
      return (
        <MenuCheckboxItem className={classes.menuItem} value={item.value}>
          {item.label}
        </MenuCheckboxItem>
      )
    case "radio-group":
      return (
        <MenuRadioGroup name={item.name} defaultValue={item.defaultValue}>
          @for (const radio of item.items; key radio.value) {
            <MenuRadioItem className={classes.menuItem} value={radio.value}>
              {radio.label}
            </MenuRadioItem>
          }
        </MenuRadioGroup>
      )
    case "submenu":
      return (
        <MenuSub>
          <MenuSubTrigger className={classes.menuItem}>
            {item.label}
          </MenuSubTrigger>
          <MenuSubContent className={classes.popup}>
            <Entries items={item.items} />
          </MenuSubContent>
        </MenuSub>
      )
  }
}

function MenubarVariant({ variant, env }: { variant: Variant; env: Env }) {
  const controller = React.useInitialValue(() =>
    variant.controller ? createMenubarController() : undefined
  )
  React.useEffect(() => {
    if (!controller) {
      return
    }
    env.controls([
      ["focus()", () => controller.focus()],
      ["isOpen()", () => controller.isOpen()],
      ["close()", () => controller.close()],
    ])
  })
  const menuProps = {
    onAction: (value: string) => env.log(`action ${value}`),
    onOpenChange: (
      open: boolean,
      details: { reason: string; source: string }
    ) => env.log(`openChange ${open} (${details.reason}, ${details.source})`),
    onCheckedChange: (checked: boolean, details: { value: string }) =>
      env.log(`${details.value} ${checked}`),
    onValueChange: (value: string) => env.log(`profile ${value}`),
  }
  if (variant.data) {
    return (
      <Menubar
        className={classes.bar}
        aria-label={variant.title}
        controller={controller}
        {...variant.options}
      >
        @for (const menu of dataMenus; key menu.trigger) {
          <Menu items={menu.items} {...menuProps}>
            <MenuTrigger className={classes.item}>{menu.trigger}</MenuTrigger>
            <MenuContent className={classes.popup}>
              <Entries items={menu.items} />
            </MenuContent>
          </Menu>
        }
      </Menubar>
    )
  }
  return (
    <Menubar
      className={classes.bar}
      aria-label={variant.title}
      controller={controller}
      {...variant.options}
    >
      <Menu {...menuProps}>
        <MenuTrigger className={classes.item}>{file.trigger}</MenuTrigger>
        <MenuContent className={classes.popup}>
          @for (const item of file.items; key item.value) {
            <MenuItem
              className={classes.menuItem}
              value={item.value}
              shortcut={item.shortcut}
              disabled={item.disabled}
            >
              {item.label}
            </MenuItem>
          }
          <MenuSub>
            <MenuSubTrigger className={classes.menuItem}>
              {"Share"}
            </MenuSubTrigger>
            <MenuSubContent className={classes.popup}>
              @for (const label of file.share; key label) {
                <MenuItem className={classes.menuItem} value={label}>
                  {label}
                </MenuItem>
              }
            </MenuSubContent>
          </MenuSub>
        </MenuContent>
      </Menu>
      <Menu {...menuProps}>
        <MenuTrigger className={classes.item}>{edit.trigger}</MenuTrigger>
        <MenuContent className={classes.popup}>
          @for (const item of edit.items; key item.value) {
            <MenuItem className={classes.menuItem} value={item.value}>
              {item.label}
            </MenuItem>
          }
        </MenuContent>
      </Menu>
      <Menu {...menuProps}>
        <MenuTrigger className={classes.item}>{view.trigger}</MenuTrigger>
        <MenuContent className={classes.popup}>
          @for (const item of view.checkboxes; key item.value) {
            <MenuCheckboxItem className={classes.menuItem} value={item.value}>
              {item.label}
            </MenuCheckboxItem>
          }
        </MenuContent>
      </Menu>
      <Menu {...menuProps}>
        <MenuTrigger className={classes.item}>{profiles.trigger}</MenuTrigger>
        <MenuContent className={classes.popup}>
          <MenuRadioGroup
            defaultValue="Benoit"
            onValueChange={(value) => env.log(`profile ${value}`)}
          >
            @for (const label of profiles.radios; key label) {
              <MenuRadioItem className={classes.menuItem} value={label}>
                {label}
              </MenuRadioItem>
            }
          </MenuRadioGroup>
          <MenuSeparator className={classes.separator} />
          <MenuItem className={classes.menuItem} value="manage">
            {"Manage…"}
          </MenuItem>
        </MenuContent>
      </Menu>
    </Menubar>
  )
}

function VariantPart({ variant, env }: { variant: Variant; env: Env }) {
  if (variant.section === "Toolbar") {
    return <ToolbarVariant variant={variant} env={env} />
  }
  return <MenubarVariant variant={variant} env={env} />
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links between, so it's told React.
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantPart variant={variant} env={env} />)
  )
}

export { mount }
