-- ====================================================================
-- SKEMA TABEL DATABASE SUPABASE (POSTGRESQL) - PROJECT UTS PEMROGRAMAN MOBILE
-- Mahasiswa: Wayan Muizul Rozzak (NIM: 2415051111) - Kelas: PTI 5A
-- Dosen: Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom
-- Teaching Assistant: Made Yuda Sadewa, S.Pd.
-- Tema: BookShelf (Personal Reading & Bookshelf Manager)
-- ====================================================================

-- 1. Buat tabel saved_books jika belum ada
CREATE TABLE IF NOT EXISTS public.saved_books (
    id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL DEFAULT '2415051111',
    book_id TEXT NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    cover_url TEXT DEFAULT '',
    description TEXT DEFAULT '',
    total_pages INTEGER NOT NULL DEFAULT 100,
    current_page INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'currently_reading', -- 'currently_reading', 'for_reading', 'read'
    reading_time_minutes INTEGER NOT NULL DEFAULT 0,
    started_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    rating NUMERIC(2,1) DEFAULT 4.5,
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE public.saved_books ENABLE ROW LEVEL SECURITY;

-- 3. Kebijakan akses (Policies) untuk Anon Key (CRUD Lengkap)
-- Kebijakan SELECT (Read)
CREATE POLICY "Allow public read access to saved_books" 
ON public.saved_books FOR SELECT 
USING (true);

-- Kebijakan INSERT (Create)
CREATE POLICY "Allow public insert to saved_books" 
ON public.saved_books FOR INSERT 
WITH CHECK (true);

-- Kebijakan UPDATE (Update)
CREATE POLICY "Allow public update to saved_books" 
ON public.saved_books FOR UPDATE 
USING (true);

-- Kebijakan DELETE (Delete)
CREATE POLICY "Allow public delete from saved_books" 
ON public.saved_books FOR DELETE 
USING (true);

-- 4. Data Seed Awal (Sesuai dengan Tampilan Screenshot UTS)
INSERT INTO public.saved_books (id, student_id, book_id, title, author, cover_url, description, total_pages, current_page, status, reading_time_minutes, rating, note)
VALUES 
('seed_dear_life', '2415051111', 'dear_life_01', 'Dear Life', 'Rachel Clarke', 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400', 'A beautiful, profound memoir about life, love, death and the transformative power of compassionate palliative care.', 140, 70, 'currently_reading', 60, 4.8, 'Buku yang sangat menyentuh tentang makna hidup dan welas asih.'),
('seed_sophies_world', '2415051111', 'sophie_world_03', 'Sophie''s World', 'Jostein Gaarder', 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400', 'Sebuah novel tentang sejarah filsafat melalui petualangan seorang gadis remaja.', 160, 38, 'currently_reading', 35, 4.6, 'Bab tentang pemikiran filsuf klasik sangat mencerahkan.'),
('seed_the_secret_cage', '2415051111', 'secret_cage_05', 'The Secret Cage', 'Alison Williams', 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=400', 'A psychological thriller about truth, secrets, and surviving confinement.', 566, 104, 'currently_reading', 90, 4.4, 'Plot misterinya sangat menegangkan!'),
('seed_harry_potter', '2415051111', 'hp_deathly_02', 'Harry Potter and the Deathly Hallows', 'J.K. Rowling', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400', 'Seri penutup petualangan epik Harry Potter mengalahkan Lord Voldemort.', 754, 23, 'currently_reading', 60, 4.9, 'Seri fantasi terbaik sepanjang masa.'),
('seed_amazon_unbound', '2415051111', 'amazon_unbound_04', 'Amazon Unbound', 'Brad Stone', 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400', 'Kisah lengkap pembangunan kerajaan inovasi teknologi global oleh Jeff Bezos.', 130, 108, 'for_reading', 45, 4.5, 'Buku yang kaya akan strategi bisnis dan kepemimpinan.'),
('seed_death_of_ivan', '2415051111', 'death_ivan_06', 'The Death Of Ivan Ilych', 'Leo Tolstoy', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400', 'Karya sastra klasik Leo Tolstoy tentang refleksi makna kehidupan dan kematian.', 189, 174, 'read', 120, 4.7, 'Selesai dibaca dengan sangat memuaskan.')
ON CONFLICT (id) DO NOTHING;
