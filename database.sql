IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210905093041_Init', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Contacts] (
    [Id] int NOT NULL IDENTITY,
    [FullName] nvarchar(50) NOT NULL,
    [Email] nvarchar(100) NOT NULL,
    [DateSent] datetime2 NOT NULL,
    [Message] nvarchar(max) NULL,
    [Phone] nvarchar(50) NULL,
    CONSTRAINT [PK_Contacts] PRIMARY KEY ([Id])
);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210909081433_Contact', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Roles] (
    [Id] nvarchar(450) NOT NULL,
    [Name] nvarchar(256) NULL,
    [NormalizedName] nvarchar(256) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Users] (
    [Id] nvarchar(450) NOT NULL,
    [HomeAdress] nvarchar(400) NULL,
    [BirthDate] datetime2 NULL,
    [UserName] nvarchar(256) NULL,
    [NormalizedUserName] nvarchar(256) NULL,
    [Email] nvarchar(256) NULL,
    [NormalizedEmail] nvarchar(256) NULL,
    [EmailConfirmed] bit NOT NULL,
    [PasswordHash] nvarchar(max) NULL,
    [SecurityStamp] nvarchar(max) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(max) NULL,
    [PhoneNumberConfirmed] bit NOT NULL,
    [TwoFactorEnabled] bit NOT NULL,
    [LockoutEnd] datetimeoffset NULL,
    [LockoutEnabled] bit NOT NULL,
    [AccessFailedCount] int NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [RoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [RoleId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_RoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_RoleClaims_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserClaims] (
    [Id] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_UserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_UserClaims_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserLogins] (
    [LoginProvider] nvarchar(450) NOT NULL,
    [ProviderKey] nvarchar(450) NOT NULL,
    [ProviderDisplayName] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_UserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_UserLogins_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_UserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UserTokens] (
    [UserId] nvarchar(450) NOT NULL,
    [LoginProvider] nvarchar(450) NOT NULL,
    [Name] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_UserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_UserTokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_RoleClaims_RoleId] ON [RoleClaims] ([RoleId]);
GO

CREATE UNIQUE INDEX [RoleNameIndex] ON [Roles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;
GO

CREATE INDEX [IX_UserClaims_UserId] ON [UserClaims] ([UserId]);
GO

CREATE INDEX [IX_UserLogins_UserId] ON [UserLogins] ([UserId]);
GO

CREATE INDEX [IX_UserRoles_RoleId] ON [UserRoles] ([RoleId]);
GO

CREATE INDEX [EmailIndex] ON [Users] ([NormalizedEmail]);
GO

CREATE UNIQUE INDEX [UserNameIndex] ON [Users] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210911084038_AddIdentity', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Category] (
    [Id] int NOT NULL IDENTITY,
    [Title] nvarchar(100) NOT NULL,
    [Description] nvarchar(max) NULL,
    [Slug] nvarchar(100) NOT NULL,
    [ParentCategoryId] int NULL,
    CONSTRAINT [PK_Category] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Category_Category_ParentCategoryId] FOREIGN KEY ([ParentCategoryId]) REFERENCES [Category] ([Id]) ON DELETE NO ACTION
);
GO

CREATE INDEX [IX_Category_ParentCategoryId] ON [Category] ([ParentCategoryId]);
GO

CREATE INDEX [IX_Category_Slug] ON [Category] ([Slug]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210914133417_AddCategory', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DROP INDEX [IX_Category_Slug] ON [Category];
GO

CREATE TABLE [Post] (
    [PostId] int NOT NULL IDENTITY,
    [Title] nvarchar(160) NOT NULL,
    [Description] nvarchar(max) NULL,
    [Slug] nvarchar(160) NULL,
    [Content] nvarchar(max) NULL,
    [Published] bit NOT NULL,
    [AuthorId] nvarchar(450) NOT NULL,
    [DateCreated] datetime2 NOT NULL,
    [DateUpdated] datetime2 NOT NULL,
    CONSTRAINT [PK_Post] PRIMARY KEY ([PostId]),
    CONSTRAINT [FK_Post_Users_AuthorId] FOREIGN KEY ([AuthorId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [PostCategory] (
    [PostID] int NOT NULL,
    [CategoryID] int NOT NULL,
    CONSTRAINT [PK_PostCategory] PRIMARY KEY ([PostID], [CategoryID]),
    CONSTRAINT [FK_PostCategory_Category_CategoryID] FOREIGN KEY ([CategoryID]) REFERENCES [Category] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PostCategory_Post_PostID] FOREIGN KEY ([PostID]) REFERENCES [Post] ([PostId]) ON DELETE CASCADE
);
GO

CREATE UNIQUE INDEX [IX_Category_Slug] ON [Category] ([Slug]);
GO

CREATE INDEX [IX_Post_AuthorId] ON [Post] ([AuthorId]);
GO

CREATE UNIQUE INDEX [IX_Post_Slug] ON [Post] ([Slug]) WHERE [Slug] IS NOT NULL;
GO

CREATE INDEX [IX_PostCategory_CategoryID] ON [PostCategory] ([CategoryID]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20210920095257_AddPost', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE [Post] DROP CONSTRAINT [FK_Post_Users_AuthorId];
GO

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Post]') AND [c].[name] = N'AuthorId');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Post] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Post] ALTER COLUMN [AuthorId] nvarchar(450) NULL;
GO

CREATE TABLE [CategoryProduct] (
    [Id] int NOT NULL IDENTITY,
    [Title] nvarchar(100) NOT NULL,
    [Description] nvarchar(max) NULL,
    [Slug] nvarchar(100) NOT NULL,
    [ParentCategoryId] int NULL,
    CONSTRAINT [PK_CategoryProduct] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_CategoryProduct_CategoryProduct_ParentCategoryId] FOREIGN KEY ([ParentCategoryId]) REFERENCES [CategoryProduct] ([Id])
);
GO

CREATE TABLE [Product] (
    [ProductID] int NOT NULL IDENTITY,
    [Title] nvarchar(160) NOT NULL,
    [Description] nvarchar(max) NULL,
    [Slug] nvarchar(160) NULL,
    [Content] nvarchar(max) NULL,
    [Published] bit NOT NULL,
    [AuthorId] nvarchar(450) NULL,
    [DateCreated] datetime2 NOT NULL,
    [DateUpdated] datetime2 NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY ([ProductID]),
    CONSTRAINT [FK_Product_Users_AuthorId] FOREIGN KEY ([AuthorId]) REFERENCES [Users] ([Id])
);
GO

CREATE TABLE [ProductCategoryProduct] (
    [ProductID] int NOT NULL,
    [CategoryID] int NOT NULL,
    CONSTRAINT [PK_ProductCategoryProduct] PRIMARY KEY ([ProductID], [CategoryID]),
    CONSTRAINT [FK_ProductCategoryProduct_CategoryProduct_CategoryID] FOREIGN KEY ([CategoryID]) REFERENCES [CategoryProduct] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_ProductCategoryProduct_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Product] ([ProductID]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_CategoryProduct_ParentCategoryId] ON [CategoryProduct] ([ParentCategoryId]);
GO

CREATE UNIQUE INDEX [IX_CategoryProduct_Slug] ON [CategoryProduct] ([Slug]);
GO

CREATE INDEX [IX_Product_AuthorId] ON [Product] ([AuthorId]);
GO

CREATE UNIQUE INDEX [IX_Product_Slug] ON [Product] ([Slug]) WHERE [Slug] IS NOT NULL;
GO

CREATE INDEX [IX_ProductCategoryProduct_CategoryID] ON [ProductCategoryProduct] ([CategoryID]);
GO

ALTER TABLE [Post] ADD CONSTRAINT [FK_Post_Users_AuthorId] FOREIGN KEY ([AuthorId]) REFERENCES [Users] ([Id]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20220106075349_Product', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [ProductPhoto] (
    [Id] int NOT NULL IDENTITY,
    [FileName] nvarchar(max) NULL,
    [ProductID] int NOT NULL,
    CONSTRAINT [PK_ProductPhoto] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_ProductPhoto_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Product] ([ProductID]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_ProductPhoto_ProductID] ON [ProductPhoto] ([ProductID]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20220107074424_ProductPhoto', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [CartDB] (
    [CartId] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NULL,
    [Content] nvarchar(max) NOT NULL,
    [CartUserName] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(max) NOT NULL,
    [Address] nvarchar(max) NOT NULL,
    [CartTotal] decimal(18,2) NOT NULL,
    [DateCreated] datetime2 NOT NULL,
    CONSTRAINT [PK_CartDB] PRIMARY KEY ([CartId]),
    CONSTRAINT [FK_CartDB_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id])
);
GO

CREATE INDEX [IX_CartDB_UserId] ON [CartDB] ([UserId]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20230417092336_AddCart', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Reviews] (
    [ReviewId] int NOT NULL IDENTITY,
    [ProductID] int NOT NULL,
    [reviewName] nvarchar(max) NOT NULL,
    [start] nvarchar(1) NOT NULL,
    [content] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Reviews] PRIMARY KEY ([ReviewId]),
    CONSTRAINT [FK_Reviews_Product_ProductID] FOREIGN KEY ([ProductID]) REFERENCES [Product] ([ProductID]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_Reviews_ProductID] ON [Reviews] ([ProductID]);
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20230421083353_AddReview', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE [CartDB] ADD [Status] nvarchar(max) NULL DEFAULT N'';
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20230423095838_AddStatus', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Reviews]') AND [c].[name] = N'start');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Reviews] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Reviews] ALTER COLUMN [start] int NOT NULL;
GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[CartDB]') AND [c].[name] = N'Status');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [CartDB] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [CartDB] ALTER COLUMN [Status] nvarchar(max) NULL;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20230430172922_ChangeTypeStart', N'6.0.1');
GO

COMMIT;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE [Product] ADD [quantity] int NOT NULL DEFAULT 0;
GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20230508045243_AddQuantity', N'6.0.1');
GO

COMMIT;
GO

