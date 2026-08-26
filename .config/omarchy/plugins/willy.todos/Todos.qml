import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

// A small todo list overlay, summoned with `omarchy-shell shell toggle willy.todos`.
// One text line drives everything: type to add, Tab to edit the selected item,
// Enter on an empty line to tick it off.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string draft: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  // -1 means the input line adds a new todo; otherwise it rewrites this one.
  property int editingIndex: -1
  property var todos: []

  readonly property string todosPath: Quickshell.env("HOME") + "/.local/state/omarchy/todos.json"

  // Shares the [menu] surface tokens, so any theme that styles the Omarchy
  // menu styles this too.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily

  // Overlay-local type scale. Style.font.* is the shell-wide rem scale the bar
  // shares, so raising it in shell.toml resizes the bar too. Scale here instead.
  property real fontScale: 1.0
  function fs(px) { return Math.max(1, Math.round(px * root.fontScale)) }
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), root.fs(Style.font.title) + Style.spacing.controlPaddingY * 2)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(560), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(520), panel.height - Style.gapsOut * 2)
  property int rowHeight: Math.max(Style.space(42), root.fs(Style.font.title) + Style.spacing.controlPaddingY * 2)

  readonly property int remaining: {
    var open = 0
    for (var i = 0; i < root.todos.length; i++)
      if (!root.todos[i].done) open++
    return open
  }

  function open(payloadJson) {
    root.opened = true
    root.draft = ""
    root.editingIndex = -1
    root.selectedIndex = 0
    root.cursorActive = root.todos.length > 0
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    root.editingIndex = -1
    root.draft = ""
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "willy.todos")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function loadTodos(raw) {
    var parsed = []
    try {
      var value = JSON.parse(raw)
      if (!Array.isArray(value)) return
      for (var i = 0; i < value.length; i++) {
        var entry = value[i]
        if (!entry || typeof entry.text !== "string") continue
        var text = entry.text.trim()
        if (!text.length) continue
        parsed.push({ text: text, done: entry.done === true })
      }
    } catch (e) {
      // Half-written or hand-mangled file: keep what's in memory rather than
      // letting the next save persist an empty list over it.
      return
    }
    root.todos = parsed
    root.rebuildDisplay()
  }

  function saveTodos() {
    todosFile.setText(JSON.stringify(root.todos, null, 2) + "\n")
  }

  function addTodo(text) {
    var trimmed = text.trim()
    if (!trimmed.length) return
    var next = root.todos.slice()
    next.unshift({ text: trimmed, done: false })
    root.todos = next
    root.selectedIndex = 0
    root.cursorActive = true
    root.saveTodos()
    root.rebuildDisplay()
  }

  function updateTodo(index, text) {
    if (index < 0 || index >= root.todos.length) return
    var trimmed = text.trim()
    // Emptying the line abandons the edit rather than deleting the todo.
    // Removal is Delete only, so a rename can never destroy an entry.
    if (!trimmed.length) return
    var next = root.todos.slice()
    next[index] = { text: trimmed, done: next[index].done }
    root.todos = next
    root.saveTodos()
    root.rebuildDisplay()
  }

  function removeTodo(index) {
    if (index < 0 || index >= root.todos.length) return
    var next = root.todos.slice()
    next.splice(index, 1)
    root.todos = next
    if (root.selectedIndex >= next.length) root.selectedIndex = Math.max(0, next.length - 1)
    root.cursorActive = next.length > 0
    root.saveTodos()
    root.rebuildDisplay()
  }

  function toggleDone(index) {
    if (index < 0 || index >= root.todos.length) return
    var next = root.todos.slice()
    next[index] = { text: next[index].text, done: !next[index].done }
    root.todos = next
    root.saveTodos()
    root.rebuildDisplay()
  }

  function beginEdit(index) {
    if (index < 0 || index >= root.todos.length) return
    root.editingIndex = index
    root.draft = root.todos[index].text
  }

  function cancelEdit() {
    root.editingIndex = -1
    root.draft = ""
  }

  function commit() {
    if (root.editingIndex >= 0) {
      // Read the draft before cancelEdit() clears it, or the rewrite arrives
      // empty and gets treated as a delete.
      var target = root.editingIndex
      var text = root.draft
      root.cancelEdit()
      root.updateTodo(target, text)
      return
    }
    if (root.draft.trim().length) {
      root.addTodo(root.draft)
      root.draft = ""
      return
    }
    if (root.cursorActive) root.toggleDone(root.selectedIndex)
  }

  function rebuildDisplay() {
    displayModel.clear()
    for (var i = 0; i < root.todos.length; i++)
      displayModel.append({ label: root.todos[i].text, done: root.todos[i].done })

    if (displayModel.count === 0) {
      root.selectedIndex = 0
      root.cursorActive = false
    } else if (root.selectedIndex >= displayModel.count) {
      root.selectedIndex = displayModel.count - 1
    } else if (root.selectedIndex < 0) {
      root.selectedIndex = 0
    }
  }

  function select(delta) {
    if (displayModel.count === 0) return
    if (!root.cursorActive) {
      root.cursorActive = true
      root.selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      root.selectedIndex = (root.selectedIndex + delta + displayModel.count) % displayModel.count
    }
    todoList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  ListModel { id: displayModel }

  FileView {
    id: todosFile
    path: root.todosPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadTodos(text())
    onLoadFailed: root.loadTodos("[]")
    onFileChanged: reload()
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "willy-todos"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.editingIndex >= 0) root.cancelEdit()
            else if (root.draft) root.draft = ""
            else root.dismiss()
            event.accepted = true
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            if (root.editingIndex >= 0) root.cancelEdit()
            else if (root.cursorActive) root.beginEdit(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if (root.cursorActive) {
              if (root.editingIndex === root.selectedIndex) root.cancelEdit()
              root.removeTodo(root.selectedIndex)
            }
            event.accepted = true
          } else if (Util.editsFilter(event, root.draft)) {
            root.draft = Util.editedFilter(event, root.draft)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.commit()
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.draft += event.text
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Item {
          width: parent.width
          height: root.headerHeight

          Text {
            id: prompt
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.editingIndex >= 0 ? "󰏫" : "󰐕"
            color: root.foreground
            opacity: 0.7
            font.family: root.fontFamily
            font.pixelSize: root.fs(Style.font.heading)
          }

          Text {
            anchors.left: prompt.right
            anchors.leftMargin: Style.space(10)
            anchors.right: counter.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            text: root.draft || (root.editingIndex >= 0 ? "Edit todo…" : "Add a todo…")
            color: root.foreground
            opacity: root.draft ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: root.fs(Style.font.heading)
            elide: Text.ElideLeft
          }

          Text {
            id: counter
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.todos.length ? root.remaining + " left" : ""
            color: root.foreground
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: root.fs(Style.font.body)
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.contentSpacing

          ListView {
            id: todoList
            anchors.fill: parent
            model: displayModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: displayModel.count > 0

            delegate: Rectangle {
              id: row
              required property int index
              required property string label
              required property bool done

              readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

              width: ListView.view.width
              height: root.rowHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"
              clip: true

              Text {
                id: box
                anchors.left: parent.left
                anchors.leftMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                text: row.done ? "󰄲" : "󰄱"
                color: row.hasCursor ? root.selectedText : root.foreground
                opacity: row.done ? 0.65 : 1.0
                font.family: root.fontFamily
                font.pixelSize: root.fs(Style.font.title)
              }

              Text {
                anchors.left: box.right
                anchors.leftMargin: Style.space(10)
                anchors.right: parent.right
                anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                text: row.label
                color: row.hasCursor ? root.selectedText : root.foreground
                opacity: row.done ? 0.5 : 1.0
                font.family: root.fontFamily
                font.pixelSize: root.fs(Style.font.title)
                font.strikeout: row.done
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) {
                  root.cursorActive = true
                  root.selectedIndex = row.index
                }
                onClicked: {
                  root.cursorActive = true
                  root.selectedIndex = row.index
                  root.toggleDone(row.index)
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰄲"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: root.fs(Style.font.displayLarge)
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              text: "Nothing to do"
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: root.fs(Style.font.title)
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }
      }
    }
  }
}
