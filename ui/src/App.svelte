<script>
  import { onMount } from "svelte";

  let pattern = null;
  let leaderboard = [];
  let loading = true;
  let error = null;
  let refreshing = false;

  async function fetchPattern() {
    try {
      loading = true;
      error = null;

      const response = await fetch("/pattern", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Failed to fetch pattern");
      }

      const data = await response.json();
      if (data.success) {
        pattern = data.pattern;
        await fetchLeaderboard(pattern.codes);
      }
    } catch (err) {
      error = err.message;
      console.error("Error fetching pattern:", err);
    } finally {
      loading = false;
      refreshing = false;
    }
  }

  async function fetchLeaderboard(codes) {
    try {
      const response = await fetch(
        `/pattern/leaderboard?codes=${encodeURIComponent(codes)}`
      );

      if (!response.ok) {
        throw new Error("Failed to fetch leaderboard");
      }

      const data = await response.json();
      if (data.success) {
        leaderboard = data.leaderboard;
      }
    } catch (err) {
      console.error("Error fetching leaderboard:", err);
      leaderboard = [];
    }
  }

  async function handleRefresh() {
    refreshing = true;
    await fetchPattern();
  }

  onMount(() => {
    fetchPattern();
    fetchLeaderboard(pattern.codes);
  });

  setInterval(() => {
    fetchLeaderboard(pattern.codes);
  }, 1000);

  function formatDate(timestamp) {
    return new Date(timestamp).toLocaleString("id-ID", {
      dateStyle: "medium",
      timeStyle: "short",
    });
  }

  function formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString("id-ID", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  }
</script>

<main class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-200 p-8">
  <div class="container mx-auto">
    <!-- Header -->
    <header class="bg-white rounded-2xl p-6 mb-8 shadow-xl">
      <div class="flex justify-between items-center flex-wrap gap-4">
        <div class="flex items-center gap-2">
          <div class="p-4 rounded-xl bg-blue-950">
            <img src="/verdex.png" alt="BatikQR" class="w-8 h-8" />
          </div>
          <h1
            class="text-4xl font-bold bg-gradient-to-r from-blue-600 to-blue-700 bg-clip-text text-transparent"
          >
            BatikQR
          </h1>
        </div>
        <button
          on:click={handleRefresh}
          disabled={refreshing}
          class="px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0"
        >
          <span class="inline-block {refreshing ? 'animate-spin' : ''}">↻</span>
          {refreshing ? "Refreshing..." : "New Pattern"}
        </button>
      </div>
    </header>

    {#if loading && !pattern}
      <div
        class="bg-white rounded-2xl p-16 shadow-xl flex flex-col items-center justify-center gap-4"
      >
        <div
          class="w-12 h-12 border-4 border-purple-200 border-t-purple-600 rounded-full animate-spin"
        ></div>
        <p class="text-slate-600 font-medium">Loading pattern...</p>
      </div>
    {:else if error}
      <div
        class="bg-white rounded-2xl p-16 shadow-xl flex flex-col items-center justify-center gap-4"
      >
        <div class="text-6xl">⚠️</div>
        <p class="text-red-600 font-medium">{error}</p>
        <button
          on:click={fetchPattern}
          class="px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl font-semibold shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200"
        >
          Try Again
        </button>
      </div>
    {:else if pattern}
      <div class="space-y-8">
        <section>
          <div class="mb-6">
            <h2 class="text-2xl font-bold text-slate-800 mb-3">
              Current Pattern
            </h2>
            <div class="flex gap-3 flex-wrap">
              <span
                class="px-4 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl text-sm font-semibold"
              >
                ID: {pattern.id}
              </span>
              <span
                class="px-4 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl text-sm font-semibold"
              >
                {formatDate(pattern.timestamp)}
              </span>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
            {#each pattern.codeArray as code, index}
              <div
                class="relative bg-gradient-to-br from-slate-50 to-slate-100 rounded-2xl transition-all duration-300 hover:-translate-y-2 hover:shadow-2xl border-2 border-transparent hover:border-purple-300"
              >
                <div
                  class="w-full aspect-square rounded-xl overflow-hidden bg-white shadow-lg"
                >
                  <img
                    src="/asset/pattern/{code}.png"
                    alt="Pattern {code}"
                    class="w-full h-full object-cover"
                  />
                </div>
                <div
                  class="text-center font-semibold text-slate-800 px-2 py-2 bg-white rounded-lg"
                >
                  {code}
                </div>
              </div>
            {/each}
          </div>
        </section>

        <aside class="bg-white rounded-2xl p-8 shadow-xl h-fit sticky top-8">
          <div class="mb-6">
            <h2
              class="text-2xl font-bold text-slate-800 mb-3 flex items-center gap-2"
            >
              Leaderboard
            </h2>
            <span
              class="inline-block px-3 py-1 bg-slate-100 text-purple-600 rounded-lg text-sm font-semibold"
            >
              {leaderboard.length} entries
            </span>
          </div>

          <div>
            {#if leaderboard.length === 0}
              <div
                class="flex flex-col items-center justify-center py-12 gap-3 text-slate-400"
              >
                <div class="text-6xl opacity-50">📋</div>
                <p class="font-medium">No entries yet</p>
                <small class="text-sm">Be the first to scan!</small>
              </div>
            {:else}
              <div class="flex flex-col gap-3">
                {#each leaderboard as entry, index}
                  <div
                    class="flex items-center gap-4 p-4 bg-gradient-to-br from-slate-50 to-slate-100 rounded-xl transition-all duration-200 hover:translate-x-1 border-2 border-transparent hover:border-purple-300 hover:shadow-lg {index <
                    3
                      ? 'from-amber-50 to-amber-100'
                      : ''}"
                  >
                    <div class="text-2xl min-w-[40px] text-center">
                      {#if index === 0}
                        <span class="text-3xl">🥇</span>
                      {:else if index === 1}
                        <span class="text-3xl">🥈</span>
                      {:else if index === 2}
                        <span class="text-3xl">🥉</span>
                      {:else}
                        <span class="text-base font-bold text-purple-600"
                          >#{index + 1}</span
                        >
                      {/if}
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="font-bold text-slate-800 truncate">
                        {entry.name}
                      </div>
                      <div class="text-sm text-purple-600 font-semibold">
                        {entry.npm}
                      </div>
                      <div class="text-xs text-slate-500">
                        {formatTime(entry.timestamp)}
                      </div>
                    </div>
                  </div>
                {/each}
              </div>
            {/if}
          </div>
        </aside>
      </div>
    {/if}
  </div>
</main>
