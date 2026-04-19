<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BuyerRequestResource\Pages;
use App\Filament\Resources\BuyerRequestResource\RelationManagers;
use App\Models\BuyerRequest;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class BuyerRequestResource extends Resource
{
    protected static ?string $model = BuyerRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                //
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                //
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBuyerRequests::route('/'),
            'create' => Pages\CreateBuyerRequest::route('/create'),
            'edit' => Pages\EditBuyerRequest::route('/{record}/edit'),
        ];
    }
}
