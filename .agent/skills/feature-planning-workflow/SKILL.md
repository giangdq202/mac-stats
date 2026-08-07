---
name: feature-planning-workflow
description: >
  Quy trình bắt buộc khi bắt đầu bất kỳ feature nào: Grill → Plan → Branch → Implement → Build → Test → Commit → Memory → Merge.
  Kích hoạt skill này TRƯỚC KHI làm bất cứ điều gì liên quan đến code mới.
---

# Skill: Feature Planning Workflow

## Quy Trình Bắt Buộc

```
GRILL → PLAN → BRANCH → IMPLEMENT → BUILD → TEST → COMMIT → MEMORY → MERGE
```

---

## Bước 1: GRILL — Hiểu Mong Muốn Thực Sự

Không bắt đầu code cho đến khi trả lời được 3 câu hỏi này:

1. **What**: Tính năng này làm gì chính xác?
2. **Why**: Tại sao cần? Vấn đề gì đang giải quyết?
3. **How**: User tương tác với nó như thế nào?

**Cách grill**:
- Hỏi từng câu một, không dump nhiều câu cùng lúc
- Đưa ra recommendation kèm reasoning
- Nếu câu trả lời mơ hồ → grill tiếp, không tự interpret

**Ví dụ grill tốt**:
> Developer: "Tôi muốn custom màu sắc"
> Agent: "Bạn muốn màu thay đổi theo ngưỡng cố định (ví dụ: >50% = vàng) hay theo gradient liên tục?"
> → Chờ trả lời trước khi hỏi câu tiếp theo

---

## Bước 2: PLAN — Chốt Plan Cụ Thể

Sau khi hiểu mong muốn, tạo plan và grill cho đến khi được approve:

```markdown
## Plan: [Tên Feature]

### Scope
- Làm: [danh sách cụ thể]
- Không làm: [explicitly out of scope]

### Files sẽ thay đổi
- `AppDelegate.swift`: [thêm gì]
- `StatusBarView.swift`: [sửa gì]

### Files KHÔNG thay đổi
- `SMC.swift` ✅
- `build.sh` (trừ khi cần) ✅

### Các bước implement
1. [Bước nhỏ 1]
2. [Bước nhỏ 2]
...

### Definition of Done
- [ ] Build thành công
- [ ] Tính năng hoạt động đúng
- [ ] Settings persist
```

**Chỉ bắt đầu code khi developer confirm plan.**

---

## Bước 3: BRANCH — Tạo Nhánh Trước

```bash
# Tạo branch từ main
git checkout main
git pull  # nếu có remote
git checkout -b feat/ten-tinh-nang

# Ví dụ:
git checkout -b feat/custom-color-thresholds
git checkout -b feat/compact-display-mode
git checkout -b fix/network-bytes-overflow
```

> ⚠️ **TUYỆT ĐỐI không commit lên `main` trực tiếp.**

---

## Bước 4: IMPLEMENT — Từng Bước Nhỏ

- Giải thích `tại sao` trước khi viết code
- Mỗi bước không quá 50 dòng code
- Code sạch, không comment thừa
- Sau mỗi bước → chạy build

---

## Bước 5: BUILD — Tự Verify

```bash
bash build.sh
```

- Nếu build lỗi → fix trước, không tiếp tục
- Báo cáo kết quả build cho developer

---

## Bước 6: TEST — Xác Nhận Hoạt Động

```bash
open MacStats.app
```

Kiểm tra checklist:
- [ ] Icon xuất hiện trên menu bar
- [ ] Tính năng mới hoạt động đúng
- [ ] Không có regression ở tính năng cũ
- [ ] Dark mode và Light mode đều đúng

---

## Bước 7: COMMIT — Conventional Commits

```bash
# Format
git commit -m "feat: add custom CPU color thresholds"
git commit -m "fix: correct memory calculation on M4"
git commit -m "refactor: extract threshold logic to helper"
git commit -m "docs: update AGENTS.md with new skill"

# Commit nhỏ và thường xuyên — mỗi bước logic là 1 commit
```

---

## Bước 8: MEMORY — Cập Nhật Sau Mỗi Commit

Sau mỗi commit, cập nhật:
- `.agent/memory/project.md` — decisions, roadmap status
- `.agent/memory/swift-learnings.md` — Swift concepts đã dùng
- `.agent/memory/build_history.log` — tự động qua post-build hook
- `.agent/memory/bugs.md` — nếu có bug/fix

---

## Bước 9: MERGE — Về Main Khi Xong

```bash
git checkout main
git merge feat/ten-tinh-nang
# Nếu có conflict → giải quyết và grill developer
```
