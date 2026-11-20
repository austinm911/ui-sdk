"use strong"
import {
  Menu,
  MenuContent,
  MenuGroup,
  MenuGroupLabel,
  MenuItem,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import * as React from "octane"
import { createRoot } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import { changedMenuGroups, menuGroups } from "tests/fixtures/menu-groups.ts"

// Groups of items the specs reorder while the menu is open.
function Fixture() {
  const [groups, setGroups] = React.useState(menuGroups)
  React.useEffect(() => onItemsChange(changedMenuGroups, setGroups))
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Menu>
        <MenuTrigger>{"Actions"}</MenuTrigger>
        <MenuContent className="popup">
          @for (const group of groups; key group.label) {
            <MenuGroup>
              <MenuGroupLabel className="label">{group.label}</MenuGroupLabel>
              @for (const item of group.items; key item.value) {
                <MenuItem className="item" value={item.value}>
                  {item.label}
                </MenuItem>
              }
            </MenuGroup>
          }
        </MenuContent>
      </Menu>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
