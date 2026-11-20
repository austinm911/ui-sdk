"use strong"
import {
  Accordion,
  AccordionHeader,
  AccordionItem,
  AccordionPanel,
  AccordionTrigger,
} from "@ui-sdk/octane/accordion"
import {
  Autocomplete,
  AutocompleteContent,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteList,
} from "@ui-sdk/octane/autocomplete"
import {
  Collapsible,
  CollapsiblePanel,
  CollapsibleTrigger,
} from "@ui-sdk/octane/collapsible"
import {
  Combobox,
  ComboboxContent,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from "@ui-sdk/octane/combobox"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import {
  Drawer,
  DrawerBackdrop,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerTitle,
  DrawerTrigger,
} from "@ui-sdk/octane/drawer"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@ui-sdk/octane/hover-card"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import {
  Popover,
  PopoverClose,
  PopoverContent,
  PopoverTrigger,
} from "@ui-sdk/octane/popover"
import {
  Resizable,
  ResizableHandle,
  ResizablePanel,
} from "@ui-sdk/octane/resizable"
import {
  ScrollArea,
  ScrollAreaContent,
  ScrollAreaScrollbar,
  ScrollAreaThumb,
  ScrollAreaViewport,
} from "@ui-sdk/octane/scroll-area"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import {
  Slider,
  SliderControl,
  SliderIndicator,
  SliderThumb,
  SliderTrack,
} from "@ui-sdk/octane/slider"
import {
  Tabs,
  TabsIndicator,
  TabsList,
  TabsPanel,
  TabsTab,
} from "@ui-sdk/octane/tabs"
import { Toolbar, ToolbarButton } from "@ui-sdk/octane/toolbar"
import { Tooltip, TooltipContent, TooltipTrigger } from "@ui-sdk/octane/tooltip"
import { Tree } from "@ui-sdk/octane/tree"
import { Waterfall } from "@ui-sdk/octane/waterfall"
import * as React from "octane"
import { createRoot } from "octane"
import {
  exposeLayers,
  leakComponent,
  leakTreeItems,
  leakWaterfallItems,
  perfItems,
} from "tests/fixtures/perf.ts"

// One component for the leak specs, picked with ?component=, and a button
// that mounts and unmounts it. The scroll area hides its scrollbars soon after
// the pointer leaves, so the spec sees them show and hide without waiting long.
const items = perfItems(3)
const lines = perfItems(30)

function LeakMenu() {
  return (
    <Menu>
      <MenuTrigger>{"Open"}</MenuTrigger>
      <MenuContent className="popup">
        @for (const item of items; key item.value) {
          <MenuItem className="item" value={item.value}>
            {item.label}
          </MenuItem>
        }
      </MenuContent>
    </Menu>
  )
}

function LeakSelect() {
  return (
    <Select defaultValue={items[0].value}>
      <SelectTrigger aria-label="Open" className="trigger">
        <SelectValue />
      </SelectTrigger>
      <SelectContent className="popup list-popup">
        @for (const item of items; key item.value) {
          <SelectItem className="item" value={item.value} label={item.label}>
            {item.label}
          </SelectItem>
        }
      </SelectContent>
    </Select>
  )
}

function LeakCombobox() {
  return (
    <Combobox>
      <ComboboxInput aria-label="Open" className="input" />
      <ComboboxContent className="popup list-popup">
        <ComboboxList>
          @for (const item of items; key item.value) {
            <ComboboxItem
              className="item"
              value={item.value}
              label={item.label}
            >
              {item.label}
            </ComboboxItem>
          }
        </ComboboxList>
      </ComboboxContent>
    </Combobox>
  )
}

function LeakAutocomplete() {
  return (
    <Autocomplete>
      <AutocompleteInput aria-label="Open" className="input" />
      <AutocompleteContent className="popup list-popup">
        <AutocompleteList>
          @for (const item of items; key item.value) {
            <AutocompleteItem className="item" value={item.label}>
              {item.label}
            </AutocompleteItem>
          }
        </AutocompleteList>
      </AutocompleteContent>
    </Autocomplete>
  )
}

function LeakPopover() {
  return (
    <Popover>
      <PopoverTrigger>{"Open"}</PopoverTrigger>
      <PopoverContent className="popup" aria-label="Details">
        {"Details."}
        <PopoverClose>{"Close"}</PopoverClose>
      </PopoverContent>
    </Popover>
  )
}

function LeakDialog() {
  return (
    <Dialog>
      <DialogTrigger>{"Open"}</DialogTrigger>
      <DialogContent className="dialog">
        <DialogTitle className="title">{"Delete it?"}</DialogTitle>
        <DialogDescription className="description">
          {"This can't be undone."}
        </DialogDescription>
        <DialogClose>{"Cancel"}</DialogClose>
      </DialogContent>
    </Dialog>
  )
}

function LeakDrawer() {
  return (
    <Drawer>
      <DrawerTrigger>{"Open"}</DrawerTrigger>
      <DrawerBackdrop className="backdrop" />
      <DrawerContent className="dialog">
        <DrawerTitle className="title">{"Move goal"}</DrawerTitle>
        <DrawerDescription className="description">
          {"Set your daily goal."}
        </DrawerDescription>
        <DrawerClose>{"Cancel"}</DrawerClose>
      </DrawerContent>
    </Drawer>
  )
}

function LeakTooltip() {
  return (
    <Tooltip>
      <TooltipTrigger>{"Open"}</TooltipTrigger>
      <TooltipContent className="tooltip">{"A hint."}</TooltipContent>
    </Tooltip>
  )
}

function LeakHoverCard() {
  return (
    <HoverCard delay={0}>
      <HoverCardTrigger href="#profile">{"Open"}</HoverCardTrigger>
      <HoverCardContent className="hover-card-content">
        {"A profile."}
      </HoverCardContent>
    </HoverCard>
  )
}

function LeakSlider() {
  return (
    <Slider name="volume" defaultValue={50}>
      <SliderControl className="slider-control">
        <SliderTrack className="slider-track">
          <SliderIndicator className="slider-indicator" />
          <SliderThumb className="slider-thumb" aria-label="Volume" />
        </SliderTrack>
      </SliderControl>
    </Slider>
  )
}

function LeakAccordion() {
  return (
    <Accordion>
      <AccordionItem value="first">
        <AccordionHeader>
          <AccordionTrigger className="accordion-trigger">
            {"Open"}
          </AccordionTrigger>
        </AccordionHeader>
        <AccordionPanel className="accordion-panel">
          {"An answer."}
        </AccordionPanel>
      </AccordionItem>
      <AccordionItem value="second">
        <AccordionHeader>
          <AccordionTrigger className="accordion-trigger">
            {"Second"}
          </AccordionTrigger>
        </AccordionHeader>
        <AccordionPanel className="accordion-panel">
          {"Another answer."}
        </AccordionPanel>
      </AccordionItem>
    </Accordion>
  )
}

function LeakCollapsible() {
  return (
    <Collapsible>
      <CollapsibleTrigger>{"Open"}</CollapsibleTrigger>
      <CollapsiblePanel className="collapsible-panel">
        {"Details."}
      </CollapsiblePanel>
    </Collapsible>
  )
}

// The panels are a component of their own: a keyed @for written beside
// <TabsList>, whose children hold a @for too, renders before the list
// (octanejs/octane#3094).
function LeakTabPanels() @{
  @for (const item of items; key item.value) {
    <TabsPanel className="panel" value={item.value}>
      {`${item.label} content.`}
    </TabsPanel>
  }
}

function LeakTabs() {
  return (
    <Tabs className="tabs" defaultValue={items[0].value}>
      <TabsList className="tablist" aria-label="Pages">
        @for (const item of items; key item.value) {
          <TabsTab className="tab" value={item.value}>
            {item.label}
          </TabsTab>
        }
        <TabsIndicator className="indicator" />
      </TabsList>
      <LeakTabPanels />
    </Tabs>
  )
}

function LeakToolbar() {
  return (
    <Toolbar className="toolbar" aria-label="Formatting">
      @for (const item of items; key item.value) {
        <ToolbarButton>{item.label}</ToolbarButton>
      }
    </Toolbar>
  )
}

function LeakTree() {
  return <Tree className="tree" aria-label="Files" items={leakTreeItems()} />
}

function LeakWaterfall() {
  return (
    <Waterfall
      className="waterfall"
      aria-label="Trace"
      items={leakWaterfallItems()}
    />
  )
}

function LeakResizable() {
  return (
    <Resizable className="resizable">
      <ResizablePanel id="first" defaultSize={50} className="resizable-panel" />
      <ResizableHandle className="resizable-handle" aria-label="Handle" />
      <ResizablePanel
        id="second"
        defaultSize={50}
        className="resizable-panel"
      />
    </Resizable>
  )
}

function LeakScrollArea() {
  return (
    <ScrollArea className="scroll-area" scrollHideDelay={50}>
      <ScrollAreaViewport
        className="scroll-area-viewport"
        role="region"
        aria-label="Items"
      >
        <ScrollAreaContent>
          @for (const line of lines; key line.value) {
            <p className="scroll-area-item">{line.label}</p>
          }
        </ScrollAreaContent>
      </ScrollAreaViewport>
      <ScrollAreaScrollbar className="scroll-area-scrollbar">
        <ScrollAreaThumb className="scroll-area-thumb" />
      </ScrollAreaScrollbar>
    </ScrollArea>
  )
}

const components = {
  menu: LeakMenu,
  select: LeakSelect,
  combobox: LeakCombobox,
  autocomplete: LeakAutocomplete,
  popover: LeakPopover,
  dialog: LeakDialog,
  drawer: LeakDrawer,
  tooltip: LeakTooltip,
  "hover-card": LeakHoverCard,
  slider: LeakSlider,
  accordion: LeakAccordion,
  collapsible: LeakCollapsible,
  tabs: LeakTabs,
  toolbar: LeakToolbar,
  tree: LeakTree,
  waterfall: LeakWaterfall,
  resizable: LeakResizable,
  "scroll-area": LeakScrollArea,
}

// Read once: Strong mode keeps render from reading the URL.
const Component = components[leakComponent()]

function Fixture() {
  const [mounted, setMounted] = React.useState(true)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      @if (mounted) {
        <Component />
      }
      <button onClick={() => setMounted((value) => !value)}>{"Toggle"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  exposeLayers()
  createRoot(root).render(<Fixture />)
}

export { mount }
