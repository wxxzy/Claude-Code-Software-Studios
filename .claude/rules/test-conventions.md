# 测试编写规约 (Testing Conventions)

适用于 `tests/**` 目录。

## 1. 结构化命名 (Structured Naming)
- **测试文件名**: `[模块名].test.[扩展名]` 或 `test_[模块名].py`。
- **测试函数名**: `test_should_[预期结果]_when_[场景]`。

## 2. Given-When-Then (GWT 模式)
- **Given**: 设置测试环境、初始化数据。
- **When**: 调用被测试的函数/方法。
- **Then**: 验证输出结果（使用断言 assert）。

## 3. 测试粒度 (Granularity)
- **单一断言**: 一个测试用例原则上只验证一个逻辑分支。
- **禁止逻辑依赖**: 每个测试必须是独立的 (Isolated)，严禁测试用例之间互相传递数据。
- **Mocking**: 外部服务（API、数据库、缓存）必须进行 Mock 处理，除非是专门的集成测试 (Integration Test)。

## 4. 覆盖率 (Coverage)
- **核心逻辑**: `src/core/**` 目录下的核心逻辑必须包含 100% 的分支覆盖。
- **边缘情况**: 每个测试必须包含至少一个正常路径 (Happy Path) 和一个错误路径 (Error Path)。
