<div>
    <x-input-label for="number" value="Numéro de l'appartement" />
    <x-text-input id="number" name="number" type="text" class="mt-1 block w-full" :value="old('number', $apartment->number ?? '')" required autofocus />
    <p class="mt-1 text-sm text-gray-500">Exemple : A1, B12…</p>
    <x-input-error class="mt-2" :messages="$errors->get('number')" />
</div>

<div>
    <x-input-label for="resident_id" value="Résident (facultatif)" />
    <select id="resident_id" name="resident_id" class="mt-1 block w-full border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 rounded-md shadow-sm">
        <option value="">— Aucun résident —</option>
        @foreach ($residents as $resident)
            <option value="{{ $resident->id }}" @selected(old('resident_id', $apartment->resident_id ?? '') == $resident->id)>
                {{ $resident->name }} ({{ $resident->email }})
            </option>
        @endforeach
    </select>
    <x-input-error class="mt-2" :messages="$errors->get('resident_id')" />
</div>
