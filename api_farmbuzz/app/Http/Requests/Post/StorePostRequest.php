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
            'image_paths' => ['nullable', 'array'],
            'image_paths.*' => ['string', 'max:1000'],
            'images' => ['nullable', 'array'],
            'images.*' => ['image', 'max:8192'],
        ];
    }

    public function after(): array
    {
        return [function ($validator): void {
            $content = trim((string) $this->input('content', ''));
            $images = $this->input('image_paths', []);
            $uploadedImages = $this->file('images', []);

            if ($content === '' && empty($images) && empty($uploadedImages)) {
                $validator->errors()->add('content', 'Post content or image is required.');
            }
        }];
    }
}
