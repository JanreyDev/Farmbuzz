<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ClubController;
use App\Http\Controllers\Api\EggCollectionController;
use App\Http\Controllers\Api\FarmController;
use App\Http\Controllers\Api\FarmGalleryController;
use App\Http\Controllers\Api\FeaturedBirdController;
use App\Http\Controllers\Api\HeritageLineController;
use App\Http\Controllers\Api\FlockController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RegistrationController;
use App\Http\Controllers\Api\SocialController;
use App\Http\Controllers\Api\StoryController;
use App\Http\Controllers\Api\TeamController;

Route::prefix('auth/register')->group(function (): void {
    Route::post('/start', [RegistrationController::class, 'start']);
    Route::post('/send-otp', [RegistrationController::class, 'sendOtp']);
    Route::post('/verify-otp', [RegistrationController::class, 'verifyOtp']);
    Route::post('/set-pin', [RegistrationController::class, 'setPin']);
});

Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/logout', [AuthController::class, 'logout']);

Route::get('/profile', [ProfileController::class, 'show']);
Route::post('/profile/media', [ProfileController::class, 'updateMedia']);
Route::post('/profile/update', [ProfileController::class, 'update']);
Route::delete('/profile', [ProfileController::class, 'destroy']);

Route::get('/farm', [FarmController::class, 'show']);
Route::post('/farm', [FarmController::class, 'store']);
Route::post('/farm/media', [FarmController::class, 'updateMedia']);
Route::delete('/farm', [FarmController::class, 'destroy']);
Route::get('/farm/heritage-lines', [HeritageLineController::class, 'index']);
Route::post('/farm/heritage-lines', [HeritageLineController::class, 'store']);
Route::put('/farm/heritage-lines/{heritageLine}', [HeritageLineController::class, 'update']);
Route::delete('/farm/heritage-lines/{heritageLine}', [HeritageLineController::class, 'destroy']);
Route::get('/farm/featured-birds', [FeaturedBirdController::class, 'index']);
Route::post('/farm/featured-birds', [FeaturedBirdController::class, 'store']);
Route::post('/farm/featured-birds/{featuredBird}', [FeaturedBirdController::class, 'update']);
Route::delete('/farm/featured-birds/{featuredBird}', [FeaturedBirdController::class, 'destroy']);
Route::get('/farm/gallery/photos', [FarmGalleryController::class, 'index']);
Route::post('/farm/gallery/photos', [FarmGalleryController::class, 'store']);
Route::delete('/farm/gallery/photos/{farmGalleryPhoto}', [FarmGalleryController::class, 'destroy']);
Route::get('/breeding/collections', [EggCollectionController::class, 'index']);
Route::post('/breeding/collections', [EggCollectionController::class, 'store']);
Route::put('/breeding/collections/{eggCollection}', [EggCollectionController::class, 'update']);
Route::delete('/breeding/collections/{eggCollection}', [EggCollectionController::class, 'destroy']);
Route::get('/flock', [FlockController::class, 'index']);
Route::post('/flock', [FlockController::class, 'store']);
Route::delete('/flock/{flockBatch}', [FlockController::class, 'destroy']);
Route::get('/team', [TeamController::class, 'index']);
Route::get('/team/invite-candidates', [TeamController::class, 'inviteCandidates']);
Route::post('/team', [TeamController::class, 'store']);
Route::delete('/team/{teamMember}', [TeamController::class, 'destroy']);
Route::get('/reports/summary', [ReportController::class, 'summary']);
Route::get('/stories', [StoryController::class, 'index']);
Route::post('/stories', [StoryController::class, 'store']);
Route::get('/social/status', [SocialController::class, 'status']);
Route::get('/social/counts', [SocialController::class, 'counts']);
Route::post('/social/follow', [SocialController::class, 'follow']);
Route::delete('/social/follow', [SocialController::class, 'unfollow']);

Route::get('/posts', [PostController::class, 'index']);
Route::post('/posts', [PostController::class, 'store']);
Route::post('/posts/{post}/like', [PostController::class, 'like']);
Route::post('/posts/{post}/unlike', [PostController::class, 'unlike']);
Route::get('/posts/{post}/comments', [PostController::class, 'comments']);
Route::post('/posts/{post}/comments', [PostController::class, 'addComment']);

Route::get('/clubs', [ClubController::class, 'index']);
Route::post('/clubs', [ClubController::class, 'store']);
Route::put('/clubs/{club}', [ClubController::class, 'update']);
Route::get('/clubs/discover', [ClubController::class, 'discover']);
Route::post('/clubs/upload-cover', [ClubController::class, 'uploadCover']);

Route::get('/messages', [MessageController::class, 'index']);
Route::post('/messages/start', [MessageController::class, 'startConversation']);
Route::get('/messages/history', [MessageController::class, 'messages']);
Route::post('/messages/send', [MessageController::class, 'send']);

Route::get('/counts', [NotificationController::class, 'counts']);
Route::get('/media', [MediaController::class, 'show']);
