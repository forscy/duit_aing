# 📚 Ringkasan Belajar — **Provider** & **Riverpod**

Dokumen ini merangkum seluruh materi yang sudah kita eksplor seputar state-management di Flutter, difokuskan pada dua pendekatan: **Provider (ChangeNotifier)** klasik dan **Riverpod**. Termasuk contoh kode mini, pola best-practice, serta recap User Story + User Acceptance Criteria (UAC) aplikasi *Duit Aing*.

---

## 1. State-Management Fundamentals yang Lintas-Framework

* **Source of truth tunggal** — satu variabel/objek untuk setiap potongan state.
* **Unidirectional data-flow** — State → UI render → user action → mutasi state.
* **Reactive subscription** — UI tidak nge-poll; cukup listen lalu rebuild.
* **Immutability** (atau treat-as-immutable) — memudahkan diff & undo.
* **Separation of concerns** — UI vs business logic vs persistence.
* **Dispose lifecycle** — bebas memory leak ketika route ditutup.

Siapa pun library-nya (Provider, Riverpod, BLoC) prinsip ini tetap sama.

---

## 2. Provider (ChangeNotifier) — Inti & Contoh

### 2.1 Building blocks

```dart
Provider<T>                 // readonly service / value
ChangeNotifierProvider<T>   // objek extends ChangeNotifier
FutureProvider / StreamProvider
ProxyProvider / MultiProvider
```

### 2.2 Contoh singkat

```dart
class Counter with ChangeNotifier {
  int value = 0;
  void inc() { value++; notifyListeners(); }
}

ChangeNotifierProvider(create: (_) => Counter())
```

Mengakses di widget:

```dart
final c = context.watch<Counter>().value;     // rebuild
context.read<Counter>().inc();                // tidak rebuild
```

### 2.3 Integrasi API (TODOS)

* `TodoRepo extends ChangeNotifier`
* Memiliki `List<Todo>? pending`, `done`, `error`, `isLoading`.
* `load()` mem‐`await Future.wait()` dua endpoint, set state, `notifyListeners()`.
* UI membaca repo, mem-render loading / error / list.

---

## 3. Riverpod — Manual & Dengan Generator

### 3.1 Manual providers

```dart
final todoApiP = Provider((_) => TodoApi());

final pendingTodosP = FutureProvider<List<Todo>>(
  (ref) => ref.read(todoApiP).fetchPending(),
);
```

Tidak perlu `BuildContext`, auto-dispose bisa ditambah `.autoDispose`.

### 3.2 Dengan `@riverpod` (generator)

```dart
@riverpod
class TodoController extends _$TodoController {
  @override Future<List<Todo>> build() => ref.read(todoApiP).fetchTodos();

  Future<void> add(String title) async { … }
  void toggle(Todo t) { … }
}
```

* Generator membuat `todoControllerProvider` secara otomatis.
* UI hanya `ref.watch(todoControllerProvider)` lalu `when()`.

### 3.3 AsyncValue pattern

```dart
final todos = ref.watch(todoControllerProvider);
return todos.when(
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Err $e'),
  data: (list) => ListView(...),
);
```

### 3.4 Deriving state

```dart
final summaryP = Provider(
  (ref) {
    final p = ref.watch(pendingTodosP);
    final d = ref.watch(doneTodosP);
    return /* AsyncValue merger */;
  },
);
```

---

## 4. Perbandingan Singkat

* Provider lebih sederhana, cocok proyek kecil; rely pada `ChangeNotifier` & `context.watch()`.
* Riverpod tidak butuh `BuildContext`, otomatis auto-dispose, gampang di-test & override.
* Generator Riverpod mengurangi boilerplate, tapi opsional.

---