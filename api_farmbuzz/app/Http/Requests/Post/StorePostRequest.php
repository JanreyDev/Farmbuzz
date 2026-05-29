<?php

namespace App\Http\Requests\Post;

use Illuminate\Foundation\Http\FormRequest;

class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'author_name' => ['required', 'string', 'max:255'],
            'author_avatar' => ['nullable', 'string', 'max:500'],
            'content' => ['nullable', 'string'],
            'meta_feeling' => ['nullable', 'string', 'max:120'],
            'meta_location' => ['nullable', 'string', 'max:255'],
            'images' => ['nullable', 'array'],
            'images.*' => ['image', 'max:20480'],
            'image_payloads' => ['nullable', 'array'],
            'image_payloads.*' => ['string'],
        ];
    }

    public function after(): array
    {
        return [function ($validator): void {
            $content = trim((string) $this->input('content', ''));
            $uploadedImages = $this->file('images', []);
            $payloadImages = $this->input('image_payloads', []);

            if ($content === '' && empty($uploadedImages) && empty($payloadImages)) {
                $validator->errors()->add('content', 'Post content or image is required.');
            }
        }];
    }
}
