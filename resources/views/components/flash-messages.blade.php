@if (session('success'))
    <div class="mb-6 rounded-md bg-green-50 border border-green-200 px-4 py-3 text-green-800 text-base">
        {{ session('success') }}
    </div>
@endif

@if (session('error'))
    <div class="mb-6 rounded-md bg-red-50 border border-red-200 px-4 py-3 text-red-800 text-base">
        {{ session('error') }}
    </div>
@endif
