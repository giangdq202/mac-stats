---
name: git-workflow
description: >
  Quy ước git cho project mac-stats: branch naming, commit format, merge strategy.
  Kích hoạt khi cần tạo branch, commit code, hoặc merge feature.
---

# Skill: Git Workflow

## Branch Naming Convention

```bash
feat/ten-tinh-nang-bang-tieng-anh   # Tính năng mới
fix/mo-ta-bug                        # Bug fix
refactor/ten-phan-can-refactor       # Refactor không thay đổi behavior
docs/cap-nhat-gi                     # Chỉ sửa docs/comments

# Ví dụ thực tế:
feat/custom-color-thresholds
feat/compact-display-mode
fix/network-bytes-overflow
refactor/color-utility-functions
docs/update-agents-md
```

## Tạo Branch

```bash
# Luôn tạo branch từ main
git checkout main
git checkout -b feat/ten-tinh-nang
```

> ⚠️ Nếu main có thay đổi chưa commit → commit hoặc stash trước.

---

## Conventional Commits

```
<type>: <description ngắn gọn>

Types:
  feat     — Tính năng mới
  fix      — Bug fix
  refactor — Refactor code (không thêm feature, không fix bug)
  docs     — Thay đổi docs, comments
  style    — Format, whitespace (không thay đổi logic)
  chore    — Build process, dependency updates
```

### Ví dụ Commit Messages

```bash
git commit -m "feat: add discrete color thresholds for CPU/RAM"
git commit -m "feat: add warn/critical threshold settings in menu"
git commit -m "fix: prevent crash when SMC returns nil temperature"
git commit -m "refactor: extract colorForThreshold() to StatusBarView"
git commit -m "docs: add git-workflow skill"
git commit -m "chore: fix SDK path in build.sh for Swift 6.2.4"
```

### Quy Tắc Commit

- Mỗi commit = 1 đơn vị logic nhỏ (không bundle nhiều thứ)
- Commit thường xuyên — sau mỗi bước nhỏ hoạt động
- Không commit code broken (build phải pass trước)
- Không commit `.app`, `*_arm64`, `*_x86_64` (đã có trong `.gitignore`)

---

## Merge Strategy

```bash
# Khi feature xong, merge về main
git checkout main
git merge feat/ten-tinh-nang

# Sau merge, xóa branch cũ (tùy chọn)
git branch -d feat/ten-tinh-nang
```

> Hiện tại chưa có remote repo → không `git push`.
> Khi có remote, sẽ update skill này.

---

## Xem Lịch Sử

```bash
git log --oneline -10       # 10 commit gần nhất
git log --oneline --graph   # Với branch graph
git diff main               # So sánh với main
git status                  # Xem files đã thay đổi
```

---

## Stash (Tạm Lưu Work In Progress)

```bash
git stash              # Lưu tạm changes chưa commit
git stash pop          # Lấy lại changes
git stash list         # Xem danh sách stashes
```
