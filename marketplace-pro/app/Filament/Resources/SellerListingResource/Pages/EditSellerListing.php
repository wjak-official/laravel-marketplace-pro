<?php

namespace App\Filament\Resources\SellerListingResource\Pages;

use App\Filament\Resources\SellerListingResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSellerListing extends EditRecord
{
    protected static string $resource = SellerListingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
