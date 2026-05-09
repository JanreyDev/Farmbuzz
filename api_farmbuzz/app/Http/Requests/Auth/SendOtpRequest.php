<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SendOtpRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'registration_id' => ['required', 'integer', 'exists:users,id'],
            'mobile_number' => [
                'required',
                'string',
                'regex:/^\+?[1-9]\d{7,14}$/',
                Rule::unique('users', 'mobile_number')->ignore($this->integer('registration_id')),
            ],
        ];
    }
}
