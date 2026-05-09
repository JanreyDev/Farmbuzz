<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class StartRegistrationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'referral_code' => ['nullable', 'string', 'max:50'],
            'is_at_least_18' => ['required', 'accepted'],
            'accepted_terms' => ['required', 'accepted'],
        ];
    }
}
